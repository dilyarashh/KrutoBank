using AccountsService.Errors.Exceptions;
using CreditsService.Data;
using CreditsService.DTO;
using CreditsService.Entities;
using CreditsService.Entities.Enums;
using CreditsService.Helper;
using CreditsService.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

namespace CreditsService.Services
{
    public class CreditService : ICreditService
    {
        private readonly ITariffRepository _tariffRepository;
        private readonly ILoanRepository _loanRepository;
        private readonly ILoanOperationRepository _loanOperationRepository;
        private readonly ILogger<CreditService> _logger;
        private readonly ICurrentUser _currentUser;

        public CreditService(ITariffRepository tariffRepository, ILoanRepository loanRepository,
            ILoanOperationRepository loanOperationRepository, ILogger<CreditService> logger, ICurrentUser currentUser)
        {
            _tariffRepository = tariffRepository;
            _loanRepository = loanRepository;
            _loanOperationRepository = loanOperationRepository;
            _logger = logger;
            _currentUser = currentUser;
        }

        public async Task<TariffResponseDto> CreateTariff(CreateTariffDto dto)
        {
            if (_currentUser.GetRole() != "Employee")
            {
                throw new ForbiddenException("Только сотрудники могут создавать тарифы");
            }

            if (dto.InterestRate <= 0 || dto.InterestRate >= 1)
            {
                throw new ArgumentException("Процентная ставка должна быть между 0 и 1");
            }

            var existingTariff = await _tariffRepository.GetByNameAsync(dto.Name);
            if (existingTariff != null)
            {
                throw new InvalidOperationException($"Тариф с названием '{dto.Name}' уже существует");
            }

            var tariff = new Tariff
            {
                Name = dto.Name,
                InterestRate = dto.InterestRate,
                CreatedAt = DateTime.UtcNow,
                IsActive = true
            };

            _tariffRepository.Add(tariff);
            await _tariffRepository.SaveChangesAsync();

            _logger.LogInformation("Создан новый тариф: {TariffName} со ставкой {Rate:P}", tariff.Name, tariff.InterestRate);

            var tariffDto = new TariffResponseDto
            {
                Id = tariff.Id,
                Name = tariff.Name,
                InterestRate = tariff.InterestRate
            };

            return tariffDto;
        }

        public async Task<List<TariffResponseDto>> GetAllTariffs()
        {
            var tariffs = await _tariffRepository.GetAllActiveAsync();

            return tariffs.Select(t => new TariffResponseDto
            {
                Id = t.Id,
                Name = t.Name,
                InterestRate = t.InterestRate
            }).ToList();
        }

        public async Task<LoanInfoDto> TakeLoan(CreateLoanDto dto)
        {
            var currentUserId = _currentUser.GetUserId();
            if (currentUserId != dto.UserId)
            {
                throw new ForbiddenException("Вы можете взять кредит только на свое имя");
            }

            if (_currentUser.GetRole() != "Client")
            {
                throw new ForbiddenException("Только клиенты могут брать кредиты");
            }

            var tariff = await _tariffRepository.GetByNameAsync(dto.TariffName);
            if (tariff == null)
            {
                throw new KeyNotFoundException($"Тариф с названием '{dto.TariffName}' не найден");
            }

            if (dto.Amount <= 0)
            {
                throw new ArgumentException("Сумма кредита должна быть положительной");
            }

            if (dto.Amount > 10000000)
            {
                throw new ArgumentException("Сумма кредита не может превышать 10 000 000");
            }

            var loan = new Loan
            {
                UserId = dto.UserId,
                TariffId = tariff.Id,
                InitialAmount = dto.Amount,
                RemainingAmount = dto.Amount,
                CreatedAt = DateTime.UtcNow,
                LastInterestApplicationDate = DateTime.UtcNow,
                IsActive = true
            };

            _loanRepository.Add(loan);
            await _loanRepository.SaveChangesAsync();

            _logger.LogInformation("Пользователь {UserId} взял кредит ID {LoanId} на сумму {Amount:C} по тарифу {TariffName}",
                dto.UserId, loan.Id, dto.Amount, tariff.Name);

            var loanInfoDto = new LoanInfoDto
            {
                LoanId = loan.Id,
                InitialAmount = loan.InitialAmount,
                RemainingAmount = loan.RemainingAmount,
                TariffName = tariff.Name,
                InterestRate = tariff.InterestRate,
                CreatedAt = loan.CreatedAt,
                IsActive = loan.IsActive
            };

            return loanInfoDto;
        }

        public async Task<LoanInfoDto> RepayLoan(RepayLoanDto dto)
        {
            var loan = await _loanRepository.GetByIdWithTariffAsync(dto.LoanId);
            if (loan == null)
            {
                throw new KeyNotFoundException($"Кредит с ID {dto.LoanId} не найден");
            }

            var currentUserId = _currentUser.GetUserId();
            if (currentUserId != loan.UserId)
            {
                throw new ForbiddenException("Вы можете гасить только свои кредиты");
            }

            if (!loan.IsActive)
            {
                throw new InvalidOperationException("Кредит уже погашен");
            }

            if (dto.Amount <= 0)
            {
                throw new ArgumentException("Сумма погашения должна быть положительной");
            }

            if (dto.Amount > loan.RemainingAmount)
            {
                throw new InvalidOperationException($"Сумма погашения превышает остаток. Остаток: {loan.RemainingAmount:C}");
            }

            loan.RemainingAmount -= dto.Amount;

            if (loan.RemainingAmount <= 0)
            {
                loan.IsActive = false;
                loan.RemainingAmount = 0;
            }

            _loanRepository.Update(loan);

            var operation = new LoanOperation
            {
                LoanId = loan.Id,
                Amount = dto.Amount,
                OperationDate = DateTime.UtcNow,
                Type = LoanOperationType.Repayment
            };

            _loanOperationRepository.Add(operation);
            await _loanOperationRepository.SaveChangesAsync();

            _logger.LogInformation("Погашение кредита ID {LoanId} на сумму {Amount:C}. Остаток: {Remaining:C}",
                loan.Id, dto.Amount, loan.RemainingAmount);

            var loanInfoDto = new LoanInfoDto
            {
                LoanId = loan.Id,
                InitialAmount = loan.InitialAmount,
                RemainingAmount = loan.RemainingAmount,
                TariffName = loan.Tariff!.Name,
                InterestRate = loan.Tariff.InterestRate,
                CreatedAt = loan.CreatedAt,
                IsActive = loan.IsActive
            };

            return loanInfoDto;
        }

        public async Task<List<LoanInfoDto>> GetUserLoans(Guid userId)
        {
            var currentUserId = _currentUser.GetUserId();
            var currentRole = _currentUser.GetRole();

            if (currentRole != "Employee" && currentUserId != userId)
            {
                throw new ForbiddenException("У вас нет прав на просмотр кредитов этого пользователя");
            }

            var loans = await _loanRepository.GetUserLoansAsync(userId);

            var loanInfoDto = loans.Select(l => new LoanInfoDto
            {
                LoanId = l.Id,
                InitialAmount = l.InitialAmount,
                RemainingAmount = l.RemainingAmount,
                TariffName = l.Tariff!.Name,
                InterestRate = l.Tariff.InterestRate,
                CreatedAt = l.CreatedAt,
                IsActive = l.IsActive
            }).ToList();

            return loanInfoDto;
        }

        public async Task<List<LoanOperationDto>> GetLoanOperations(Guid userId, Guid loanId)
        {
            var loan = await _loanRepository.GetByIdAsync(loanId);
            if (loan == null)
            {
                throw new KeyNotFoundException($"Кредит с ID {loanId} не найден");
            }

            if (loan.UserId != userId)
            {
                throw new ForbiddenException("Кредит не принадлежит указанному пользователю");
            }

            var currentUserId = _currentUser.GetUserId();
            var currentRole = _currentUser.GetRole();

            if (currentRole != "Employee" && currentUserId != loan.UserId)
            {
                throw new ForbiddenException("У вас нет прав на просмотр операций этого кредита");
            }

            var operations = await _loanOperationRepository.GetByLoanIdAsync(loanId);

            var loanoperationDto = operations.Select(o => new LoanOperationDto
            {
                OperationId = o.Id,
                Amount = o.Amount,
                OperationDate = o.OperationDate,
                OperationType = o.Type == LoanOperationType.Interest ? "Начисление процентов" : "Погашение"
            }).ToList();

            return loanoperationDto;
        }

        public async Task AccrueInterestForAll()
        {
            var startTime = DateTime.UtcNow;
            _logger.LogInformation("=== НАЧАЛО НАЧИСЛЕНИЯ ПРОЦЕНТОВ: {time} ===", startTime);

            using var transaction = await _loanRepository.BeginTransactionAsync();

            try
            {
                var activeLoans = await _loanRepository.GetActiveLoansWithTariffAsync();

                if (!activeLoans.Any())
                {
                    _logger.LogInformation("Нет активных кредитов для начисления процентов");
                    return;
                }

                _logger.LogInformation("Найдено активных кредитов: {count}", activeLoans.Count);

                var totalInterestAmount = 0m;
                var operations = new List<LoanOperation>();

                foreach (var loan in activeLoans)
                {
                    try
                    {
                        // Расчет процентов (остаток * процентная ставка тарифа)
                        var interestAmount = loan.RemainingAmount * loan.Tariff!.InterestRate;

                        var oldAmount = loan.RemainingAmount;
                        loan.RemainingAmount += interestAmount;
                        loan.LastInterestApplicationDate = DateTime.UtcNow;

                        _loanRepository.Update(loan);

                        var operation = new LoanOperation
                        {
                            LoanId = loan.Id,
                            Amount = interestAmount,
                            OperationDate = DateTime.UtcNow,
                            Type = LoanOperationType.Interest
                        };

                        operations.Add(operation);
                        totalInterestAmount += interestAmount;

                        _logger.LogDebug("Кредит ID {loanId}: {oldAmount:C} -> {newAmount:C}, начислено {interest:C}",
                            loan.Id, oldAmount, loan.RemainingAmount, interestAmount);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Ошибка при обработке кредита ID {loanId}", loan.Id);
                    }
                }

                _loanOperationRepository.AddRange(operations);

                await _loanOperationRepository.SaveChangesAsync();
                await transaction.CommitAsync();

                var duration = DateTime.UtcNow - startTime;
                _logger.LogInformation("=== НАЧИСЛЕНИЕ ЗАВЕРШЕНО: обработано {count} кредитов, всего начислено {totalInterest:C}, время: {duration} ===",
                    activeLoans.Count, totalInterestAmount, duration);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                _logger.LogError(ex, "КРИТИЧЕСКАЯ ОШИБКА при начислении процентов");
                throw;
            }
        }
    }
}

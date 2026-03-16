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
        private readonly IAccountClient _accountClient;
        private readonly IUserClient _userClient;
        private readonly CreditsDbContext _dbContext;

        public CreditService(ITariffRepository tariffRepository, ILoanRepository loanRepository,
            ILoanOperationRepository loanOperationRepository, ILogger<CreditService> logger, 
            ICurrentUser currentUser, IAccountClient accountClient, IUserClient userClient, CreditsDbContext dbContext)
        {
            _tariffRepository = tariffRepository;
            _loanRepository = loanRepository;
            _loanOperationRepository = loanOperationRepository;
            _logger = logger;
            _currentUser = currentUser;
            _accountClient = accountClient;
            _userClient = userClient;
            _dbContext = dbContext;
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
            var userExists = await _userClient.UserExists(dto.UserId);

            if (!userExists)
            {
                throw new NotFoundException("Пользователь не существует");
            }

            var currentUserId = _currentUser.GetUserId();
            if (currentUserId != dto.UserId)
            {
                throw new ForbiddenException("Вы можете взять кредит только на свое имя");
            }

            if (_currentUser.GetRole() != "Client")
            {
                throw new ForbiddenException("Только клиенты могут брать кредиты");
            }

            var isMyAccount = await _accountClient.IsMyAccount(dto.AccountId);

            if (!isMyAccount)
            {
                throw new ForbiddenException("Вы можете получить кредит только на свой счет");
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

            var bankAccount = await _accountClient.GetMasterAccountAsync();

            if (bankAccount.Balance < dto.Amount)
            {
                throw new InvalidOperationException("Недостаточно средств на мастер-счете банка");
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

            try
            {
                await _accountClient.TransferAsync(BankAccounts.MasterAccountId, dto.AccountId, dto.Amount);

                _loanRepository.Add(loan);
                await _loanRepository.SaveChangesAsync();
            }
            catch
            {
                throw new InvalidOperationException("Не удалось оформить кредит. Попробуйте позже.");
            }

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
                throw new KeyNotFoundException($"Кредит {dto.LoanId} не найден");
            }    

            var currentUserId = _currentUser.GetUserId();

            if (currentUserId != loan.UserId)
            {
                throw new ForbiddenException("Вы можете гасить только свои кредиты");
            }

            var isOwnerAccount = await _accountClient.IsAccountOwnedByUser(dto.AccountId, loan.UserId);

            if (!isOwnerAccount)
            {
                throw new ForbiddenException("Счет не принадлежит владельцу кредита");
            }

            if (!loan.IsActive)
            {
                throw new InvalidOperationException("Кредит уже погашен");
            }

            if (dto.Amount <= 0)
            {
                throw new ArgumentException("Сумма должна быть положительной");
            }

            if (dto.Amount > loan.RemainingAmount)
            {
                throw new InvalidOperationException("Сумма превышает остаток");
            }

            // списываем деньги
            await _accountClient.WithdrawAsync(dto.AccountId, dto.Amount);

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

            return new LoanInfoDto
            {
                LoanId = loan.Id,
                InitialAmount = loan.InitialAmount,
                RemainingAmount = loan.RemainingAmount,
                TariffName = loan.Tariff!.Name,
                InterestRate = loan.Tariff.InterestRate,
                CreatedAt = loan.CreatedAt,
                IsActive = loan.IsActive
            };
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

        public async Task SetupAutoPayment(CreateAutoPaymentDto dto)
        {
            var loan = await _loanRepository.GetByIdAsync(dto.LoanId);

            if (loan == null)
            {
                throw new NotFoundException("Кредит не найден");
            }

            var currentUserId = _currentUser.GetUserId();

            if (loan.UserId != currentUserId)
            {
                throw new ForbiddenException("Это не ваш кредит");
            }

            var isMyAccount = await _accountClient.IsMyAccount(dto.AccountId);

            if (!isMyAccount)
            {
                throw new ForbiddenException("Счет не принадлежит пользователю");
            }

            var autoPayment = new AutoPayment
            {
                Id = Guid.NewGuid(),
                LoanId = dto.LoanId,
                AccountId = dto.AccountId,
                Amount = dto.Amount,
                IntervalMinutes = dto.IntervalMinutes,
                CreatedAt = DateTime.UtcNow,
                NextExecutionDate = DateTime.UtcNow.AddMinutes(dto.IntervalMinutes),
                IsActive = true
            };

            _dbContext.AutoPayments.Add(autoPayment);

            await _dbContext.SaveChangesAsync();
        }

        public async Task ProcessAutoPayments()
        {
            var now = DateTime.UtcNow;

            var payments = await _dbContext.AutoPayments
                .Where(p => p.IsActive && p.NextExecutionDate <= now)
                .ToListAsync();

            foreach (var payment in payments)
            {
                try
                {
                    await RepayLoan(new RepayLoanDto
                    {
                        LoanId = payment.LoanId,
                        AccountId = payment.AccountId,
                        Amount = payment.Amount
                    });

                    payment.NextExecutionDate = now.AddMinutes(payment.IntervalMinutes);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Ошибка автоплатежа {paymentId}", payment.Id);
                }
            }

            await _dbContext.SaveChangesAsync();
        }

        public async Task<CreditScoreDto> GetCreditScore(Guid userId)
        {
            var loans = await _loanRepository.GetUserLoansAsync(userId);

            var active = loans.Count(l => l.IsActive);
            var closed = loans.Count(l => !l.IsActive);

            var overdue = loans.Count(l => l.IsActive && l.LastInterestApplicationDate.AddMinutes(15) < DateTime.UtcNow);

            var score = 100 - overdue * 10 - active * 5 + closed * 5;

            if (score < 0)
                score = 0;

            return new CreditScoreDto
            {
                UserId = userId,
                Score = score,
                ActiveLoans = active,
                ClosedLoans = closed,
                OverduePayments = overdue
            };
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

using AccountsService.DTO;

namespace AccountsService.Services
{
    public class CurrencyService
    {
        private readonly HttpClient _httpClient;

        public CurrencyService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<decimal> Convert(decimal amount, string from, string to)
        {
            var url = $"https://api.exchangerate.host/convert?from={from}&to={to}&amount={amount}";

            var response = await _httpClient.GetFromJsonAsync<ExchangeResponse>(url);

            return response!.Result;
        }
    }
}

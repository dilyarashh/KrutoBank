namespace UsersService.Infrastructure.Helpers
{
    public static class PhoneHelper
    {
        public static string Normalize(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
                return phone;

            var digits = new string(phone.Where(char.IsDigit).ToArray());

            if (digits.StartsWith("8"))
                digits = "7" + digits.Substring(1);

            if (!digits.StartsWith("7"))
                digits = "7" + digits;

            return digits;
        }
    }
}

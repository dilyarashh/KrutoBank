struct PhoneFormatter: TextInputFormatter {
    private let phoneMask: String = "+7##########"

    func format(_ text: String) -> String {
        var filteredText = text.filter("0123456789".contains(_:))

        if filteredText.first == "7" {
            filteredText.removeFirst()
        }

        var formattedText = ""
        var index = 0
        var stringIndex: String.Index = filteredText.startIndex

        if filteredText.isEmpty {
            while index < phoneMask.count && phoneMask[stringIndex] != "#" {
                formattedText += String(phoneMask[stringIndex])
                index += 1
                stringIndex = phoneMask.index(phoneMask.startIndex, offsetBy: index)
            }
        }

        while !filteredText.isEmpty && formattedText.count < phoneMask.count {
            let char = phoneMask[stringIndex]

            if char == "#" {
                formattedText += String(filteredText.removeFirst())
            } else {
                formattedText += String(char)
            }

            index += 1
            stringIndex = phoneMask.index(phoneMask.startIndex, offsetBy: index)
        }

        return formattedText
    }
}

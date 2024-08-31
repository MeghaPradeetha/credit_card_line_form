part of credit_card_line_form;

class CreditCardLineForm extends StatefulWidget {
  final String? cardNumberLabel;
  final String? cardHolderLabel;
  final bool hideCardHolder;
  final String? expiredDateLabel;
  final String? cvcLabel;
  final Widget? cvcIcon;
  final int cardNumberLength;
  final int cvcLength;
  final double fontSize;
  final CreditCardTheme? theme;
  final Function(CreditCardResult) onChanged;
  final CreditCardController? controller;

  const CreditCardLineForm({
    super.key,
    this.theme,
    required this.onChanged,
    this.cardNumberLabel,
    this.cardHolderLabel,
    this.hideCardHolder = false,
    this.expiredDateLabel,
    this.cvcLabel,
    this.cvcIcon,
    this.cardNumberLength = 16,
    this.cvcLength = 4,
    this.fontSize = 16,
    this.controller,
  });

  @override
  State<CreditCardLineForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardLineForm> {
  late Map<String, dynamic> params;
  late Map<String, TextEditingController> controllers;
  String error = '';
  CardType? cardType;
  late Map cardImg;

  @override
  void initState() {
    super.initState();

    params = {
      "card": '',
      "expired_date": '',
      "card_holder_name": '',
      "cvc": '',
    };

    controllers = {
      "card": TextEditingController(),
      "expired_date": TextEditingController(),
      "card_holder_name": TextEditingController(),
      "cvc": TextEditingController(),
    };

    cardImg = {
      "img": 'credit_card.png',
      "width": 30.0,
    };

    handleController();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? CreditCardLightTheme();

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border.all(color: theme.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildCardNumberField(theme),
          if (!widget.hideCardHolder) _buildCardHolderField(theme),
          Row(
            children: [
              Expanded(child: _buildExpiryDateField(theme)),
              Expanded(child: _buildCVCField(theme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardNumberField(CreditCardTheme theme) {
    return TextInputWidget(
      theme: theme,
      fontSize: widget.fontSize,
      controller: controllers['card'],
      label: widget.cardNumberLabel ?? 'Card number',
      bottom: 1,
      formatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.cardNumberLength),
        CardNumberInputFormatter(),
      ],
      onChanged: (val) {
        setState(() {
          cardImg = CardUtils.getCardIcon(val);
          cardType = CardUtils.getCardTypeFrmNumber(val.replaceAll(' ', ''));
          params['card'] = val;
        });
        emitResult();
      },
      suffixIcon: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'images/${cardImg['img']}',
          package: 'credit_card_form',
          width: cardImg['width'] as double?,
        ),
      ),
    );
  }

  Widget _buildCardHolderField(CreditCardTheme theme) {
    return TextInputWidget(
      theme: theme,
      fontSize: widget.fontSize,
      label: widget.cardHolderLabel ?? 'Card holder name',
      controller: controllers['card_holder_name'],
      bottom: 1,
      onChanged: (val) {
        setState(() {
          params['card_holder_name'] = val;
        });
        emitResult();
      },
      keyboardType: TextInputType.name,
    );
  }

  Widget _buildExpiryDateField(CreditCardTheme theme) {
    return TextInputWidget(
      theme: theme,
      fontSize: widget.fontSize,
      label: widget.expiredDateLabel ?? 'MM/YY',
      right: 1,
      onChanged: (val) {
        setState(() {
          params['expired_date'] = val;
        });
        emitResult();
      },
      controller: controllers['expired_date'],
      formatters: [
        CardExpirationFormatter(),
        LengthLimitingTextInputFormatter(5),
      ],
    );
  }

  Widget _buildCVCField(CreditCardTheme theme) {
    return TextInputWidget(
      theme: theme,
      fontSize: widget.fontSize,
      label: widget.cvcLabel ?? 'CVC',
      controller: controllers['cvc'],
      password: true,
      onChanged: (val) {
        setState(() {
          params['cvc'] = val;
        });
        emitResult();
      },
      formatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.cvcLength),
      ],
      suffixIcon: Padding(
        padding: const EdgeInsets.all(8),
        child: widget.cvcIcon ??
            Image.asset(
              'images/cvc.png',
              package: 'credit_card_form',
              height: 25,
            ),
      ),
    );
  }

  void emitResult() {
    final res = params['expired_date'].split('/');
    final result = CreditCardResult(
      cardNumber: params['card'].replaceAll(' ', ''),
      cvc: params['cvc'],
      cardHolderName: params['card_holder_name'],
      expirationMonth: res.isNotEmpty ? res[0] : '',
      expirationYear: res.length > 1 ? res[1] : '',
      cardType: cardType,
    );
    widget.onChanged(result);
  }

  void handleController() {
    widget.controller?.addListener(() {
      final initialValue = widget.controller?.value;
      if (initialValue != null) {
        controllers['card']?.value = _formatCardNumber(initialValue.cardNumber);
        controllers['card_holder_name']?.text =
            initialValue.cardHolderName ?? '';
        controllers['expired_date']?.value =
            _formatExpiryDate(initialValue.expiryDate);
      }
    });
  }

  TextEditingValue _formatCardNumber(String? cardNumber) {
    if (cardNumber == null) return const TextEditingValue();

    var formattedValue =
        FilteringTextInputFormatter.digitsOnly.formatEditUpdate(
      const TextEditingValue(text: ''),
      TextEditingValue(text: cardNumber),
    );

    formattedValue = LengthLimitingTextInputFormatter(19).formatEditUpdate(
      const TextEditingValue(text: ''),
      formattedValue,
    );

    return CardNumberInputFormatter().formatEditUpdate(
      const TextEditingValue(text: ''),
      formattedValue,
    );
  }

  TextEditingValue _formatExpiryDate(String? expiryDate) {
    if (expiryDate == null) return const TextEditingValue();

    return CardExpirationFormatter().formatEditUpdate(
      const TextEditingValue(text: ''),
      TextEditingValue(text: expiryDate),
    );
  }
}

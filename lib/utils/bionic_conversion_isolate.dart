import 'package:flutter/cupertino.dart';

import '../services/text_converter_service.dart';

class BionicConverterPayload {
  final String pageText;
  final TextStyle baseStyle;
  final TextStyle boldStyle;

  BionicConverterPayload(this.pageText, this.baseStyle, this.boldStyle);
}

// Top-level function for isolate
List<TextSpan> convertPageToBionicTextIsolate(BionicConverterPayload payload) {
  final converter = BionicTextConverter(
    baseStyle: payload.baseStyle,
    boldStyle: payload.boldStyle,
    fixateLength: 3,
  );
  return converter.convert(payload.pageText);
}
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_controller.dart';

final _uiCacheProvider = Provider<UiTranslateCache>((ref) => UiTranslateCache());

class UiTranslateCache {
  final _map = HashMap<String, String>(); // key: lang|text
  String? get(String lang, String text) => _map['$lang|$text'];
  void put(String lang, String text, String v) => _map['$lang|$text'] = v;
}

class TrText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  const TrText(this.text, {super.key, this.style, this.textAlign, this.maxLines, this.overflow});

  @override
  ConsumerState<TrText> createState() => _TrTextState();
}

class _TrTextState extends ConsumerState<TrText> {
  String? _tr;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _kick();
  }

  Future<void> _kick() async {
    final lang = ref.read(localeProvider).languageCode;
    if (lang == 'en') { setState(() => _tr = widget.text); return; }
    final cache = ref.read(_uiCacheProvider);
    final cached = cache.get(lang, widget.text);
    if (cached != null) { setState(() => _tr = cached); return; }
    if (_loading) return; _loading = true;
    try {
      final url = Uri.https('translate.googleapis.com', '/translate_a/single', {
        'client': 'gtx', 'sl': 'auto', 'tl': lang, 'dt': 't', 'q': widget.text,
      });
      final res = await Dio().getUri(url);
      String out = widget.text;
      final data = res.data;
      if (data is List && data.isNotEmpty && data[0] is List && data[0][0] is List && data[0][0][0] is String) {
        out = data[0][0][0] as String;
      }
      cache.put(lang, widget.text, out);
      if (mounted) setState(() => _tr = out);
    } catch (_) {
      if (mounted) setState(() => _tr = widget.text);
    } finally { _loading = false; }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_tr ?? widget.text, style: widget.style, textAlign: widget.textAlign, maxLines: widget.maxLines, overflow: widget.overflow);
  }
}


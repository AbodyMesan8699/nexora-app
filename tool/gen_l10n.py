#!/usr/bin/env python3
"""Generate lib/l10n_gen/app_localizations.dart from the ARB files."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "lib" / "l10n"
OUT = ROOT / "lib" / "l10n_gen" / "app_localizations.dart"

def load(loc):
    with (BASE / f"app_{loc}.arb").open(encoding="utf-8") as f:
        raw = json.load(f)
    return raw, {k: v for k, v in raw.items() if not k.startswith("@")}

en_raw, en = load("en")
_, ar = load("ar")
keys = list(en.keys())

def camel(k):
    parts = k.split("_")
    return parts[0] + "".join(p.title() for p in parts[1:])

def fmt(s):
    return s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")

def _generate_map(m):
    items = ", ".join(f"'{k}': '{fmt(v)}'" for k, v in m.items())
    return "{" + items + "}"

params = {}
for k, v in en.items():
    ms = re.findall(r"\{(\w+)\}", v)
    if ms:
        params[k] = ms

def param_type(key, name):
    placeholder = en_raw.get(f"@{key}", {}).get("placeholders", {}).get(name, {})
    return placeholder.get("type", "int")

getters = []
for k in keys:
    name = camel(k)
    if k in params:
        ps = params[k]
        plist = ", ".join(f"{param_type(k, p)} {p}" for p in ps)
        args = "{" + ", ".join(f"'{p}': {p}" for p in ps) + "}"
        getters.append(f"  String {name}({plist}) => _t('{fmt(k)}', {args});")
    else:
        getters.append(f"  String get {name} => _t('{fmt(k)}');")

src = f"""// GENERATED from lib/l10n/app_en.arb and app_ar.arb — do not edit by hand.
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {{
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const localizationsDelegates = _NexLocDelegates.all;

  static AppLocalizations of(BuildContext context) =>
      AppLocalizations(Localizations.localeOf(context));

  static bool isRtl(Locale l) => l.languageCode == 'ar';

  static const _en = {_generate_map(en)};
  static const _ar = {_generate_map(ar)};

  String _t(String key, [Map<String, Object>? args]) {{
    var s = (locale.languageCode == 'ar' ? _ar : _en)[key] ?? _en[key] ?? key;
    if (args != null) {{
      args.forEach((k, v) {{
        s = s.replaceAll('{{' + k + '}}', v is num ? NumberFormat.decimalPattern().format(v) : v.toString());
      }});
    }}
    return s;
  }}

  {chr(10).join(getters)}
}}

class _NexLocDelegates {{
  static const List<LocalizationsDelegate<dynamic>> all = [
    AppLocalizationsDelegate(),
    _FallbackMaterialDelegate(),
    _FallbackCupertinoDelegate(),
    _FallbackWidgetsDelegate(),
  ];
}}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {{
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale l) => ['en', 'ar'].contains(l.languageCode);
  @override
  Future<AppLocalizations> load(Locale l) async => AppLocalizations(l);
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}}

class _FallbackMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {{
  const _FallbackMaterialDelegate();
  @override
  bool isSupported(Locale l) => true;
  @override
  Future<MaterialLocalizations> load(Locale l) async => _NexMaterialLocalizations(l);
  @override
  bool shouldReload(_FallbackMaterialDelegate old) => false;
}}

class _NexMaterialLocalizations extends DefaultMaterialLocalizations {{
  final Locale locale;
  _NexMaterialLocalizations(this.locale);
  @override
  ui.TextDirection get textDirection =>
      locale.languageCode == 'ar' ? ui.TextDirection.rtl : ui.TextDirection.ltr;
}}

class _FallbackCupertinoDelegate extends LocalizationsDelegate<Object> {{
  const _FallbackCupertinoDelegate();
  @override
  bool isSupported(Locale l) => true;
  @override
  Future<Object> load(Locale l) async => Object();
  @override
  bool shouldReload(_FallbackCupertinoDelegate old) => false;
}}

class _FallbackWidgetsDelegate extends LocalizationsDelegate<Object> {{
  const _FallbackWidgetsDelegate();
  @override
  bool isSupported(Locale l) => true;
  @override
  Future<Object> load(Locale l) async => Object();
  @override
  bool shouldReload(_FallbackWidgetsDelegate old) => false;
}}
"""

OUT.parent.mkdir(parents=True, exist_ok=True)
with OUT.open("w", encoding="utf-8") as f:
    f.write(src)
print(f"wrote {OUT} with {len(keys)} keys")

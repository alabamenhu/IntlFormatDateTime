# IntlFormatDateTime

> Hoy es siempre todavía, toda la vida es ahora. Y ahora, ahora es el momento de cumplir las promesas que nos hicimos. Porque ayer no lo hicimos, porque mañana es tarde. Ahora.  
> — *Proverbios y cantares* (Antonio Machado)

A module for formatting dates and times in a variety of languages and styles.  To use, simple include the module:

```
use Intl::Format::DateTime
    
my $dt = DateTime.new: now;

format-date $dt;      # Format the date only
format-time $dt;      # Format the time only
format-datetime $dt;  # Format the date and time together
```

The command options are
  * **`:length`**  
The main option, sets the length.  Acceptable values are either *full*, *long*, *medium* (default), *short*.  For the most verbose, choose *wide*.  Defaults to *medium* which should be optimal in most cases.
  * **`:skeleton`** (alias **`:like`**)  
Accepts a string representing various formatting options documented in [TR 35.4.8](https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table).  The optimal pattern is chosen based on the given skeleton, deferring to the skeleton for minor differences (e.g. number of digits).  If used, **length** option is ignored.  
  * **`:language`**  
Sets the language to be used in formatting.  Acceptable values are a `LanguageTag` or a `Str` representation thereof.  Defaults to whatever `User::Language` provides, which itself defaults to `en` (English).
  * **`:relative-to`**  
**NYI**.  This option will create a relative time offset based on the the interval.  Generally `:relative-to(now)` is what you will want to use, but you can use anything that can coerce to a DateTime.  

**☞** If you use a format length which includes a non–offset-based timezone (generally all *wide* formats), **you must include `use DateTime::Timezones`** somewhere in your main script until a precompilation bug dealing with multidispatch can be fixed in Rakudo.

## To do

  * Finish skeleton patterns support (allowing selection of more specific formats).
  * Support non-Latin digits for languages that prefer them.
  * Respect capitalization rules per CLDR casing data.
  * Handle non-Gregorian calendars (once a `DateTime::Calendars` module or similar is available)
  * Handle relative time formats (though this may ultimately go into a separate module).
  
The non-Latin digits, though in theory simple enough to implement, will require rewriting almost every reference to numbers in each of the 100+ formatters.
All formatters are currently planned to be rewritten once RakuAST is committed to core, so rather than rewrite things twice, the digits will wait until then.
Case handling will probably be implemented at that time as well.

## Dependencies

  * `Intl::UserLanguage`  
  (determines the default language for formatting).  It in turn depends on `Intl::LanguageTag`
  * `Intl::CLDR`  
  Contains formatting information
  * `DateTime::Timezones`  
  Not a formal dependency due to a precompilation bug in Rakudo, but required in the main script for most `wide` formats.  
Its use will be checked for in such cases to try to provide a helpful error.

These modules are designed to work together, and as of 2021, are maintained by the same person so should not have issues if fully updated.

## Version history

  * **v0.2.0**
    * Skeleton formats supported for `format-datetime` (NYI: missing fields and C/j/J formatters NYI)
  * **v0.1**
    * Initial release

## Copyright and License

© 2021 Matthew Stephen Stuckwisch. All files licensed under the Artistic License 2.0 except for `resources/metaZones.xml` which is owned by Unicode, Inc. and licensed under the Unicode License Agreement (found at `resources/unicode-license.txt`)
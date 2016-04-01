# Description:
#   Allows Hubot to know many languages.
#
# Commands:
#   hubot translate me <phrase> - Searches for a translation for the <phrase> and then prints that bad boy out.
#   hubot translate me from <source> into <target> <phrase> - Translates <phrase> from <source> into <target>. Both <source> and <target> are optional

languages =
  "af": "Afrikaans",
  "sq": "Albanian",
  "ar": "Arabic",
  "az": "Azerbaijani",
  "eu": "Basque",
  "bn": "Bengali",
  "be": "Belarusian",
  "bg": "Bulgarian",
  "ca": "Catalan",
  "zh-CN": "Simplified Chinese",
  "zh-TW": "Traditional Chinese",
  "hr": "Croatian",
  "cs": "Czech",
  "da": "Danish",
  "nl": "Dutch",
  "en": "English",
  "eo": "Esperanto",
  "et": "Estonian",
  "tl": "Filipino",
  "fi": "Finnish",
  "fr": "French",
  "gl": "Galician",
  "ka": "Georgian",
  "de": "German",
  "el": "Greek",
  "gu": "Gujarati",
  "ht": "Haitian Creole",
  "iw": "Hebrew",
  "hi": "Hindi",
  "hu": "Hungarian",
  "is": "Icelandic",
  "id": "Indonesian",
  "ga": "Irish",
  "it": "Italian",
  "ja": "Japanese",
  "kn": "Kannada",
  "ko": "Korean",
  "la": "Latin",
  "lv": "Latvian",
  "lt": "Lithuanian",
  "mk": "Macedonian",
  "ms": "Malay",
  "mt": "Maltese",
  "no": "Norwegian",
  "fa": "Persian",
  "pl": "Polish",
  "pt": "Portuguese",
  "ro": "Romanian",
  "ru": "Russian",
  "sr": "Serbian",
  "sk": "Slovak",
  "sl": "Slovenian",
  "es": "Spanish",
  "sw": "Swahili",
  "sv": "Swedish",
  "ta": "Tamil",
  "te": "Telugu",
  "th": "Thai",
  "tr": "Turkish",
  "uk": "Ukrainian",
  "ur": "Urdu",
  "vi": "Vietnamese",
  "cy": "Welsh",
  "yi": "Yiddish"

getCode = (language,languages) ->
  for code, lang of languages
      return code if lang.toLowerCase() is language.toLowerCase()

module.exports = (robot) ->
  language_choices = (language for _, language of languages).sort().join('|')
  pattern = new RegExp('translate(?: me)?' +
                       "(?: from (#{language_choices}))?" +
                       "(?: (?:in)?to (#{language_choices}))?" +
                       '(.*)', 'i')
  robot.respond pattern, (msg) ->
    term   = "\"#{msg.match[3]?.trim()}\""
    target = if msg.match[2] isnt undefined then getCode(msg.match[2], languages) else 'en'
    lang = if msg.match[1] isnt undefined then "#{getCode(msg.match[1], languages)}-#{target}" else target
    console.log lang

    msg.http("https://translate.yandex.net/api/v1.5/tr.json/translate")
      .query({
        key: 'trnsl.1.1.20160401T182909Z.2f5ea9566adf53fc.a5fb64c6d9636df8a2d4dbb3f64fb8df8d25004b'
        text: term
        format: 'plain'
        lang: lang
      })
      .header('User-Agent', 'Mozilla/5.0')
      .get() (err, res, body) ->
        if err
          msg.send "Failed to connect to GAPI"
          robot.emit 'error', err, res
          return

        try
          if body
            parsed = JSON.parse body
            language = parsed.lang.split "-"
            texts = parsed.text
            for k,v of texts
              console.log "#{k} --> #{v}"
              text = v
            console.log "1st: #{text}"
            if text is undefined
              text = texts
            console.log "2nd: #{text}"
            if text
              if msg.match[2] is undefined
                msg.send "#{term} is #{languages[language[0]]} for #{text}"
              else
                msg.send "The #{languages[language[0]]} #{term} translates as #{text} in #{languages[target]}"
          else
            msg.send body
            throw new SyntaxError 'Invalid JS code'

        catch err
          msg.send "Failed to parse GAPI response"
          robot.emit 'error', err

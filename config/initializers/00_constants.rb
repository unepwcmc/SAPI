# Certain characters (e.g. cyrillic) will break the latex pdf generation.
# This is overly conservative, there are no doubt many punctuation characters
# which are also not going to break.
PDF_SAFE_REGEX = /\A[\x20-\x7f\p{Latin}‘’“”–]*\z/
MESSAGE_SHOULD_BE_PDF_SAFE = 'should only contain PDF-safe characters'

# Strings which match this regex have no leading or trailing spaces
TRIMMED_REGEX = /\A(?!\s).*(?<!\s)\z/
MESSAGE_SHOULD_BE_TRIMMED = 'should only contain PDF-safe characters'

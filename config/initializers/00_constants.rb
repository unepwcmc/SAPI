# Certain characters (e.g. cyrillic) will break the latex pdf generation.
# This is overly conservative, there are no doubt many punctuation characters
# which are also not going to break.
PDF_SAFE_REGEX = /\A[\x20-\x7f\p{Latin}‘’“”–]*\z/

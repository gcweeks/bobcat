#!/usr/bin/env python

import sys
import nltk
import re

# Get input string
text = sys.argv[1]

# Remove any words with odd symbols
r = re.compile(r'^[A-Za-z0-9_-]*$')
words = [word.split("'", 1)[0] for word in text.split()]
words = list(filter(r.match, words))

# Filter down to only nouns
for t in nltk.pos_tag(words):
    if t[1][0] == 'N':
        print(t[0], end=' ')

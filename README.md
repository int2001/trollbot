trollbot
========

Trollingers letzter Fall

--------

Vorraussetzungen:

- Config-File in etc mit den passenden Credentials (API-Keys) von Twitter befüllen:
	- consumer_key / consumer_secret sowie token und token_secret gibts bei dev.twitter.com
	- lastid erstmal auf 1 lassen (Hier wird die letzte ID gespeichert, auf die geantwortet wurde)
	- lastret auch auf 1 lassen (Hier wird der letzte "geklaute" Tweet gespeichert)
	- retweetname - Hier den Twitternamen (ohne @) des zu trollenden Twitterers einsetzen

---------

Was macht es?

- Alle Mentions FAVen
- Aus einem Array antworten
- Tweets klauen :)
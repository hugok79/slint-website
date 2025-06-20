#!/bin/sh
# Run this script from  the root of the clone of:
# https://github.com/DidierSpaier/slint-website

# The whole website accessed from https://slint.fr can be rebuilt locally after an update.
# You can make a local rsync on the Apache server: $WIP/html => /var/www/htdocs to check the
# website locally
# All pages are in folders by language, not in the web site directory.
# The header of most pages include the list of languages in which it is available
# This is true for: HandBook.html, home.html, news.html, support.html and wiki.html
#
# If a page is not translated in a given language, it is displayed in English
# The list of languages will not be included in the header of non translated
# pages, currently translate.html rm -rf slint-translations and
# internationalization_and_localization_of_shell_scripts.html
# All pages include a header with links to:
# Home Documentation Download Support Translate Wiki
# with the exception of pages included in the archived old website like
# https://slint.fr/old/index.html

# PO files use the ll_TT scheme, but unless there be several locales per language,
# we store the web pages in directories named $ll the per language directories.
# We build separately headers files for the translated files, which include a line
# of languages in other languages in which each page is available.
# To select the languages to include we need to know in which languages each page
# has been translated. 

# Before running this script, insure that all files in asciidoc format in
# sub-directories of:
# https://github.com/DidierSpaier/slint-translations/translations/
# be up to date running from its root po4a with as argument the relevant
# .cfg file in the `configuration` folder and the --no-update option.

# Most sources pages, in asciidoc format and their translations are stored in
# https://github.com/DidierSpaier/slint-translations/ that we clone here
rm -rf slint-translations
# If not already done...
# git clone https://github.com/DidierSpaier/slint-translations/
# Here for testing, I use a clone not yet in sync the remote repository
cp -r /data/github/slint-translations .|| exit
CWD="$(pwd)"
rm -rf wip/*
mkdir -p wip/html/doc
WIP="$CWD"/wip
rm -rf tmp/*
mkdir -p tmp/headers tmp/headers_wiki
TMP="$CWD"/tmp
SLINTDOCS="$CWD/slint-translations"

header_HandBook() {
	# We append to each file in "$CWD"/headers a list of languages in which
	# HandBook is available, as found in "$SLINTDOCS"/translations/HandBook
	cp "$SLINTDOCS"/sources/HandBook/HandBook.adoc \
	"$SLINTDOCS"/translations/HandBook/en_US.HandBook.adoc || exit
	langs="$(find "$SLINTDOCS"/translations/HandBook -name  "*adoc"|sed 's#.*/##'|cut -d_ -f1)"
	header_HandBook="$(echo "$langs"|sort|while read -r i; do echo "* link:../$i/HandBook.html[${i#./}] "; done)"
	echo "$header_HandBook" > "$TMP"/header_HandBook
	(cd "$CWD"/headers || exit
	for i in *.adoc; do
		cat "$i" "$TMP"/header_HandBook "$CWD"/headers/bottom > "$TMP"/headers/"$i"
	done
	)
}

header_support() {
	# We append to each file in "$CWD"/headers a list of languages in which
	# HandBook is available, as found in "$SLINTDOCS"/translations/HandBook
	# as the support.html is extracted from HandBool.html 
	cp "$SLINTDOCS"/sources/HandBook/HandBook.adoc \
	"$SLINTDOCS"/translations/HandBook/en_US.HandBook.adoc || exit
	langs="$(find "$SLINTDOCS"/translations/HandBook -name  "*adoc"|sed 's#.*/##'|cut -d_ -f1)"
	header_support="$(echo "$langs"|sort|while read -r i; do echo "* link:../$i/support.html[${i#./}] "; done)"
	echo "$header_support" > "$TMP"/header_support
	(cd "$CWD"/headers || exit
	for i in *.adoc; do
		cat "$i" "$TMP"/header_support "$CWD"/headers/bottom > "$TMP/headers/$i"
	done
	)
}

header_homepage() {
	# We append to each file in "$CWD"/headers a list of languages in which
	# homepage is available, as found in "$SLINTDOCS"/translations/homepage
	cp "$SLINTDOCS"/sources/homepage/homepage.adoc \
	"$SLINTDOCS"/translations/homepage/en_US.homepage.adoc || exit
	langs="$(find "$SLINTDOCS"/translations/homepage -name  "*adoc"|sed 's#.*/##'|cut -d_ -f1)"
	header_homepage="$(echo "$langs"|sort|while read -r i; do echo "* link:../$i/home.html[${i#./}] "; done)"
	echo "$header_homepage" > "$TMP"/header_homepage
	(cd "$CWD"/headers || exit
	for i in *.adoc; do
		cat "$i" "$TMP"/header_homepage "$CWD"/headers/bottom > "$TMP"/headers/"$i"
	done
	)
}

header_news() {
	# We append to each file in "$CWD"/headers a list of languages in which
	# news is available, as found in "$SLINTDOCS"/translations/news
	cp "$SLINTDOCS"/sources/news/news.adoc \
	"$SLINTDOCS"/translations/news/en_US.news.adoc || exit
	langs="$(find "$SLINTDOCS"/translations/news -name  "*adoc"|sed 's#.*/##'|cut -d_ -f1)"
	header_news="$(echo "$langs"|sort|while read -r i; do echo "* link:../$i/news.html[${i#./}] "; done)"
	echo "$header_news" > "$TMP"/header_news
	(cd "$CWD"/headers || exit
	for i in *.adoc; do
		cat "$i" "$TMP"/header_news "$CWD"/headers/bottom > "$TMP"/headers/"$i"
	done
	)
}

header_wiki() {
	# We consider that the wiki has been translated in a given language as soon
	# as one of its articles has been translated in this langage.
	cd "$SLINTDOCS/translations/wiki" || exit
	articles="$(find . -type d -mindepth 1 -maxdepth 1|sed 's#..##'|sort)"
	echo "$articles"|while read -r article; do 
		cp "$SLINTDOCS/sources/wiki/$article/${article}.adoc" \
			"$article/en_US.${article}.adoc" || exit
	done
	# We display in English the non translated articles.
	locales="$(find . -name "*.adoc"|sed 's#.*/##'|cut -d. -f1|sort|uniq)"
	langs="$(echo "$locales"|cut -d_ -f1)"
	for ll_TT in $locales; do		
		echo "$articles"|while read -r article; do
		if [ ! -f "$article/${ll_TT}.${article}.adoc" ]; then
			cp "$article/en_US.${article}.adoc" \
			"$article/${ll_TT}.${article}.adoc" || exit
		fi
		done
	done
	header_wiki="$(echo "$langs"|sort|while read -r i; do echo "* link:../$i/wiki.html[${i#./}] "; done)"
	echo "$header_wiki"|sort|uniq > "$TMP"/headers_wiki/header_wiki
	(cd "$CWD"/headers || exit
	for i in *.adoc; do
		cat "$i" "$TMP"/headers_wiki/header_wiki "$CWD"/headers/bottom_wiki > "$TMP"/headers_wiki/"$i"
		# Rename "$ll_TT.header.adoc" as "ll_TT.wiki.adoc" as initially they
		# are identical.
		rename header wiki "$TMP"/headers_wiki/"$i"
	done
	# We have now in "$TMP"/headers_wiki/ the localized wiki pages, without
	# the links to the included articles that we will add in feed_wiki.
	)
}

feed_HandBook14_2_1 () {
	cd "$SLINTDOCS"/translations/HandBook14.2.1 || exit 1
	# Rranslations of the old HandBook being frozen the list of langages is fix. 
	langs=$(echo "de el en es fr it ja nl pl pt pt_BR ru sv uk"|sed "s/ /\n/g")
	header_oldhandbook="$(echo "$langs"|while read -r i; do echo "* link:../$i/oldHandBook.html[${i#./}] "; done)"
	echo "$header_oldhandbook" > "$TMP"/header_oldhandbook
	(cd "$CWD"/headers || exit
	for i in *.adoc; do
		cat "$i" "$TMP"/header_oldhandbook "$CWD"/headers/bottom > "$TMP"/headers/"$i"
	done
	)
	find . -name "*.adoc"|sed 's#..##'|while read -r i; do
		ll_TT="${i%.*.*}"
		cat "$TMP/headers/${ll_TT}.header.adoc" "$i" > bif
		mv bif "$i"
		ll="${ll_TT%_*}"
		mkdir -p "$WIP"/html/"$ll"
		asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
		copycss="$CWD"/css/slint.css -D "$WIP" -a doctype=book "$i" -o bof
		sed 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
		"$WIP"/bof > "$WIP"/html/"$ll"/HandBook.html
				if [ "$ll_TT" = "pt_BR" ]; then
			asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
			copycss="$CWD/css/slint.css" -D "$WIP" -a doctype=book \
			"${ll_TT}.oldHandBook.adoc" -o "$WIP"/html/"$ll_TT"/oldHandBook.html
			sed -i 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
			"$WIP"/html/"$ll_TT"/oldHandBook.html
		else
			asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
			copycss="$CWD/css/slint.css" -D "$WIP" -a doctype=book \
			"${ll_TT}.oldHandBook.adoc" -o "$WIP"/html/"$ll"/oldHandBook.html
			sed -i 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
			"$WIP"/html/"$ll"/oldHandBook.html
		fi
	done
}	

feed_HandBook() {
	( cd "$SLINTDOCS"/translations/HandBook || exit 1
	cp "$SLINTDOCS"/sources/HandBook/HandBook.adoc en_US.HandBook.adoc || exit
	# list the locales in which a translation of the HandBook is available.
	langs="$(find . -name  "*adoc"|sed 's#..##'|cut -d_ -f1)"
	find . -name "*.adoc"|sed 's#..##'|while read -r i; do
		ll_TT="${i%.*.*}"
		cat "$TMP/headers/${ll_TT}.header.adoc" "$i" > bif
		mv bif "$i"
		ll="${ll_TT%_*}"
		mkdir -p "$WIP"/html/"$ll"
		asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
		copycss="$CWD"/css/slint.css -D "$WIP" -a doctype=book "$i" -o bof
		sed 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
		"$WIP"/bof > "$WIP"/html/"$ll"/HandBook.html
	done
	)
}

feed_support() {
	( cd "$SLINTDOCS"/translations/HandBook || exit 1
	cp "$SLINTDOCS"/sources/HandBook/HandBook.adoc en_US.HandBook.adoc || exit
	# The Support page is just an extract of the HandBook, so list
	# the locales in which a translation of the HandBook is available.
	langs="$(find . -name  "*adoc"|sed 's#..##'|cut -d_ -f1)"
	find . -name "*.adoc"|sed 's#..##'|while read -r i; do
		ll_TT="${i%.*.*}"
		cat "$TMP/headers/${ll_TT}.header.adoc" "$i" > bif
		mv bif "$i"
		ll="${ll_TT%_*}"
		# We convert the headers level 2 of the HandBook to level 1 in Support
		# hence s@===@==@
		sed -n "\@// Support@,\@// Acknowledgments@p" "$i"|head -n -1  \
		| sed "s@// .*@[.debut]@;s@===@==@" > "$WIP/${ll_TT}.support.part.adoc"	
		mkdir -p "$WIP"/html/"$ll"
		cat "$TMP"/headers/"$ll_TT".header.adoc "$WIP"/"${ll_TT}".support.part.adoc \
		> "$WIP"/"${ll_TT}".support.adoc
		asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
		copycss="$CWD"/css/slint.css \
		-D "$WIP" -a doctype=book "$WIP/${ll_TT}.support.adoc" -o bof
		sed 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
		"$WIP"/bof > "$WIP"/html/"$ll"/support.html
	done
	)
}

feed_homepage() {
	( cd "$SLINTDOCS"/translations/homepage || exit 1
	cp "$SLINTDOCS"/sources/homepage/homepage.adoc en_US.homepage.adoc || exit
	# list the locales in which a translation of the homepage is available.
	langs="$(find . -name  "*adoc"|sed 's#..##'|cut -d_ -f1)"
	find . -name "*.adoc"|sed 's#..##'|while read -r i; do
		ll_TT="${i%.*.*}"
		cat "$TMP/headers/${ll_TT}.header.adoc" "$i" > bif
		mv bif "$i"
		ll="${ll_TT%_*}"
		mkdir -p "$WIP"/html/"$ll"
		asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
		copycss="$CWD"/css/slint.css -D "$WIP" -a doctype=book "$i" -o bof
		sed 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
		"$WIP"/bof > "$WIP"/html/"$ll"/home.html
	done
	)
}

feed_news() {
	( cd "$SLINTDOCS"/translations/news || exit 1
	cp "$SLINTDOCS"/sources/news/news.adoc en_US.news.adoc || exit
	# list the locales in which a translation of the news is available.
	langs="$(find . -name  "*adoc"|sed 's#..##'|cut -d_ -f1)"
	find . -name "*.adoc"|sed 's#..##'|while read -r i; do
		ll_TT="${i%.*.*}"
		ll="${ll_TT%_*}"
		cat "$TMP/headers/${ll_TT}.header.adoc" "$i" > bif
		mv bif "$i"
		#  echo "$ll_TT" >> "$WIP"/languages ?
		mkdir -p "$WIP"/html/"$ll"
		asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
		copycss="$CWD"/css/slint.css -D "$WIP" -a doctype=book "$i" -o bof
		sed 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
		"$WIP"/bof > "$WIP"/html/"$ll"/news.html
	done
	)
}


feed_wiki() {
	cd "$SLINTDOCS"/translations/wiki || exit 1
	articles="$(find . -type d -mindepth 1 -maxdepth 1|sed 's#..##'|sort)"
	echo "$articles"|while read -r article; do 
		cp "$SLINTDOCS/sources/wiki/$article/${article}.adoc" \
			"$article/en_US.${article}.adoc" || exit
	done
	# List all locales of translations of articles included in the wiki
	locales="$(find . -name "*.adoc"|sed 's#.*/##'|cut -d. -f1|sort|uniq)"
	# For each article of the wiki, if a translation in a given locale is not
	# available, replace it by en_US.
	for article in $articles; do
		mkdir -p "$TMP/$article"
		for ll_TT in $locales; do
			ll="${ll_TT%_*}"
			mkdir -p "$WIP"/html/"$ll"
			echo "include::$SLINTDOCS/translations/wiki/$article/${ll_TT}.${article}.adoc[ ]" \
			>>"$TMP"/headers_wiki/"$ll_TT".wiki.adoc
			asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
			copycss="$CWD"/css/slint.css -D "$WIP" -a doctype=book \
			"$TMP/headers_wiki/${ll_TT}.wiki.adoc"  -o "$TMP"/bof
			sed 's@<p><a@<a@;s@</a></p>@</a>@;/langmen/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
			"$TMP"/bof > "$WIP"/html/"$ll"/wiki.html
		done
	done
	cd "$CWD" || exit
}

# Note: if feed_HandBook14_2_1 is run after feed_HandBook the pages Handbook.html
# are the same as oldHandBook.html. I did not find why yet - Didier 18 June 2025
cp htaccess/.htaccess wip/html
feed_HandBook14_2_1
header_support
feed_support
header_HandBook
feed_HandBook
header_homepage
feed_homepage
header_news
feed_news
header_wiki
feed_wiki
# 
cp "$CWD"/doc/*.png "$WIP"/html/doc/
asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
copycss="$CWD"/css/slint.css -D "$WIP" "$CWD"/doc/translate_slint.adoc \
-o "$WIP"/html/doc/translate_slint.html
sed -i 's@<p><a@<a@;s@</a></p>@</a>@;/"toc"/s@.*@<p></p>\n&@;/"toc"/s@.*@<p></p>\n&@' \
"$WIP"/html/doc/translate_slint.html
asciidoctor -a stylesdir=../css -a stylesheet=slint.css -a linkcss -a \
copycss="$CWD"/css/slint.css -D "$WIP" \
"$CWD"/doc/internationalization_and_localization_of_shell_scripts.adoc -o "\
$WIP"/html/doc/internationalization_and_localization_of_shell_scripts.html
cp "$CWD"/doc/shell_and_bash_scripts.html "$WIP"/html/doc/ || exit 1
cp -r "$CWD"/css "$WIP"/html
# Uncomment the following line to check the web site locally
sudo rsync --verbose -avP --exclude-from="$CWD"/exclude -H --delete-after \
 "$CWD"/wip/html/ /var/www/htdocs/
rm -rf "$CWD"/homepage "$CWD"/wiki "$CWD"/HandBook "$CWD"/HandBook14.2.1 "$CWD"/news
# run from the VPS
# su
# sh rsync_website

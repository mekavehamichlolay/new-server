FROM php:8.0-apache as mediawiki
ARG MEDIAWIKI_MAJOR_VERSION_=1_39
# Version
ENV MEDIAWIKI_MAJOR_VERSION 1.39
ENV MEDIAWIKI_VERSION 1.39.6

RUN set -eux; \
	mkdir -p /var/www/html/w; \
	chown -R www-data:www-data /var/www/html

# MediaWiki setup
RUN set -eux; \
	fetchDeps=" \
	gnupg \
	dirmngr \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	\
	cd /var/www/html/w; \
	curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz; \
	curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz.sig" -o mediawiki.tar.gz.sig; \
	export GNUPGHOME="$(mktemp -d)"; \
	# gpg key from https://www.mediawiki.org/keys/keys.txt
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys \
	D7D6767D135A514BEB86E9BA75682B08E8A3FEC4 \
	441276E9CCD15F44F6D97D18C119E1A64D70938E \
	F7F780D82EBFB8A56556E7EE82403E59F9F8CD79 \
	1D98867E82982C8FE0ABC25F9B69B3109D3BB7B0 \
	; \
	gpg --batch --verify mediawiki.tar.gz.sig mediawiki.tar.gz; \
	tar -x --strip-components=1 -f mediawiki.tar.gz; \
	gpgconf --kill all; \
	rm -r "$GNUPGHOME" mediawiki.tar.gz.sig mediawiki.tar.gz; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $fetchDeps; \
	rm -rf /var/lib/apt/lists/*;

RUN set -eux;\
	skinDir="/var/www/html/w/skins"; \
	cd "${skinDir}"; \
	skin="CologneBlue"; \
	curl -fSL "https://github.com/wikimedia/mediawiki-skins-${skin}/archive/refs/heads/REL${MEDIAWIKI_MAJOR_VERSION_}.tar.gz" -o "${skinDir}/${skin}.tar.gz"; \
	[ ! -d "${skinDir}/${skin}" ] && mkdir "${skinDir}/${skin}"; \
	tar -x --strip-components=1 -f "${skinDir}/${skin}.tar.gz" -C "${skinDir}/${skin}"; \
	rm "${skinDir}/${skin}.tar.gz"

RUN set -eux;\
	skinDir="/var/www/html/w/skins"; \
	cd "${skinDir}"; \
	skin="Modern"; \
	curl -fSL "https://github.com/wikimedia/mediawiki-skins-${skin}/archive/refs/heads/REL${MEDIAWIKI_MAJOR_VERSION_}.tar.gz" -o "${skinDir}/${skin}.tar.gz"; \
	[ ! -d "${skinDir}/${skin}" ] && mkdir "${skinDir}/${skin}"; \
	tar -x --strip-components=1 -f "${skinDir}/${skin}.tar.gz" -C "${skinDir}/${skin}"; \
	rm "${skinDir}/${skin}.tar.gz"; 

RUN	chown -R www-data:www-data /var/www/html/w/skins /var/www/html/w/cache /var/www/html/w/images; 

FROM php:8.0-apache as extensions

ARG MEDIAWIKI_MAJOR_VERSION_=1_39
RUN set -eux; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
	wget \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	mkdir -p /var/www/html/w /var/www/html/w/extensions 

COPY modified.sh /var/www/html/w/extensions/

RUN set -eu; \
	cd /var/www/html/w/extensions; \
	chmod +x modified.sh; \
	./modified.sh --version "${MEDIAWIKI_MAJOR_VERSION_}" \
	DeleteBatch \
	JsonConfig \
	CheckUser \
	WikimediaBadges \
	WikiLove \
	TwoColConflict \
	RevisionSlider \
	Popups \
	PageViewInfo \
	MobileFrontend \
	Lockdown \
	googleAnalytics \
	GeoData \
	Flow \
	Elastica \
	EditSubpages \
	DismissableSiteNotice \
	Disambiguator \
	CommonsMetadata \
	cldr \
	CirrusSearch \
	BetaFeatures \
	AdvancedSearch \
	ConfirmEdit \
	TimedMediaHandler \
	PagedTiffHandler \
	3D \
	HitCounters \
	YouTube \
	wikihiero  \
	TemplateStyles  \
	Score  \
	MetaMaster  \
	LabeledSectionTransclusion  \
	Kartographer  \
	Graph  \
	timeline  \
	CountDownClock  \
	CategoryTree  \
	CodeEditor  \
	UserMerge  \
	TemplateSandbox  \
	MassMessage  \
	Maintenance  \
	Linter  \
	Editcount  \
	Echo  \
	DiscussionTools \
	MagicNoCache \
	Thanks  \
	UniversalLanguageSelector \
	CategoryLockdown \
	CentralAuth \
	HeadScript \
	; \
	chown -R www-data:www-data /var/www/html/w/extensions

RUN rm /var/www/html/w/extensions/modified.sh

FROM php:8.0-apache as server

# System dependencies
RUN set -eux; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
	git \
	librsvg2-bin \
	imagemagick \
	# Required for SyntaxHighlighting
	python3 \
	# custom dependencies added
	cron \  
	supervisor \ 
	locales \ 
	ploticus \ 
	fonts-freefont-ttf \
	djvulibre-bin \
	netpbm \
	ffmpeg \
	# need for composer
	zip \ 
	# not sure we need to install seprate
	wget \ 
	liblua5.1-dev \
	; \
	rm -rf /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
	libicu-dev \
	libonig-dev \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
	calendar \
	intl \
	mbstring \
	mysqli \
	opcache \
	; \
	\
	pecl install APCu-5.1.21 luasandbox; \
	docker-php-ext-enable \
	apcu \
	luasandbox \
	; \
	rm -r /tmp/pear; \
	\
	# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
	| awk '/=>/ { print $3 }' \
	| sort -u \
	| xargs -r dpkg-query -S \
	| cut -d: -f1 \
	| sort -u \
	| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

COPY apache2.conf /etc/apache2/apache2.conf
# Enable Short URLs
RUN set -eux; \
	a2enmod rewrite; \
	{ \
	echo "<Directory /var/www/html>"; \
	echo "  DirectoryIndex /w/index.php"; \
	echo "  RewriteEngine On"; \
	echo "  RewriteRule ^.*rest\.php(.*)$ %{DOCUMENT_ROOT}/w/rest.php?title=\$1 [L]"; \
	echo "  RewriteRule ^/?wiki(/.*)?$ %{DOCUMENT_ROOT}/w/index.php [L]"; \
	echo "  RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-f"; \
	echo "  RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} !-d"; \
	echo "  RewriteRule ^(.*)$ %{DOCUMENT_ROOT}/w/index.php [L]"; \
	echo "</Directory>"; \
	} > "$APACHE_CONFDIR/conf-available/short-url.conf"; \
	a2enconf short-url

# Enable AllowEncodedSlashes for VisualEditor
RUN sed -i "s/<\/VirtualHost>/\tAllowEncodedSlashes NoDecode\n<\/VirtualHost>/" "$APACHE_CONFDIR/sites-available/000-default.conf"

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=60'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Set the locale
RUN set -eux; \
	sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# install composer
RUN set -eux; \
	curl -sS https://getcomposer.org/installer | php -- \
	--filename=composer

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# set supervisor
RUN set -eux; \
	mkdir -p /var/log/supervisor
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# add htaccess file in root directory
COPY .htaccess /var/www/html

FROM server
# change install dir to w
RUN set -eux; \
	mkdir -p /var/www/html/w; \
	chown -R www-data:www-data /var/www/html

COPY --chown=www-data:www-data --from=mediawiki /var/www/html/w /var/www/html/w
COPY --chown=www-data:www-data --from=extensions /var/www/html/w /var/www/html/extensions

RUN set -eu; \
	cd /var/www/html/w; \ 
	mv composer.local.json-sample composer.local.json; \
	composer install --no-dev

RUN chown -R www-data:www-data /tmp

CMD ["/usr/bin/supervisord"]

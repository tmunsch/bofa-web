# BofaNodes web image

nginx + PHP-FPM for the BofaNodes web eggs (WordPress, WP infinite, Drupal, and other PHP apps). It replaces `ghcr.io/sigma-production/nginx-ptero`.

* **Official PHP image underneath** (`php:<version>-fpm-alpine`), so PHP security fixes arrive as soon as they're released.
* **OPcache on**, tuned for sites whose files change (it re-checks files every 2 seconds, so plugin and core updates show up right away).
* **Extensions** WordPress, Drupal, Laravel and most PHP apps want: apcu, bcmath, bz2, calendar, exif, gd, gmp, igbinary, imagick, intl, mysqli, opcache, pcntl, pdo_mysql, pdo_pgsql, pgsql, redis, soap, sockets, xsl, zip (plus everything the official image already includes).
* **Tools:** bash, composer, WP-CLI (`wp`), git, curl, zip/unzip, mariadb client.
* **Rebuilt every Monday** by GitHub Actions, so Alpine, nginx and PHP updates reach your servers without you changing anything.
* Images: `ghcr.io/<you>/bofanodes-web:8.2`, `:8.3`, `:8.4`.

## Set it up (once)

1. Create a new GitHub repository, for example `bofanodes-web`, and upload these files to it (keep the `.github/workflows` and `php` folders).
2. Open the repository's **Actions** tab. The **Build web images** run starts by itself after the upload; if not, click **Build web images → Run workflow**. The first build takes about 10–15 minutes.
3. Make the images public so your nodes can pull them without logging in: on your GitHub profile, open **Packages → bofanodes-web → Package settings → Change visibility → Public**.

## Use it in the eggs

In **Admin → Nests →** each web egg (WordPress, WP infinite, Drupal, ...) **→ Docker Images**, replace the Sigma images with:

| Name | Image |
| --- | --- |
| PHP 8.3 (recommended) | `ghcr.io/<you>/bofanodes-web:8.3` |
| PHP 8.4 | `ghcr.io/<you>/bofanodes-web:8.4` |
| PHP 8.2 | `ghcr.io/<you>/bofanodes-web:8.2` |

Existing servers: on each server's **Startup** tab, pick the new image and restart. No reinstall is needed; the server's files, nginx and PHP-FPM config stay as they are.

New weekly builds reach a server when Wings pulls the image again, which it normally does when the server starts. If a server still reports an old build, reinstall it or run `docker pull ghcr.io/<you>/bofanodes-web:8.3` on the node.

## Per-server PHP settings

Any `.ini` file in a server's `php-fpm/conf.d/` folder is read after the image's defaults, for example `php-fpm/conf.d/uploads.ini`:

```ini
upload_max_filesize=256M
post_max_size=256M
memory_limit=512M
```

Restart the server to apply it.

## Defaults

| Setting | Value |
| --- | --- |
| memory_limit | 256M |
| upload_max_filesize / post_max_size | 64M |
| max_execution_time | 120 |
| max_input_vars | 3000 |
| OPcache memory | 128 MB, 20,000 files |
| APCu | 32 MB |

Change them in `php/bofanodes.ini` and `php/opcache.ini`; the next build picks them up.

## Adding a PHP version

Add it to `matrix.php` in `.github/workflows/build.yml`, for example `["8.2", "8.3", "8.4", "8.5"]`, and add the image to the eggs. If an extension isn't available for a brand-new PHP version yet, that version's build fails on its own and the others still publish.

## ARM nodes

The images are built for x86 (amd64). For ARM nodes, change `platforms` in the workflow to `linux/amd64,linux/arm64` (builds take several times longer).

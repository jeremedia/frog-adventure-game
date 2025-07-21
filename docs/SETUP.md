# GitHub Pages Setup Instructions

## Enable GitHub Pages

1. Go to: https://github.com/jeremedia/frog-adventure-game/settings/pages
2. Under "Source", select "Deploy from a branch"
3. Under "Branch", select "main" and "/docs" folder
4. Click "Save"

## Access Your Site

After a few minutes, your site will be available at:
- https://jeremedia.github.io/frog-adventure-game/

If you want to use the custom domain configured in CNAME:
- https://frog-adventure.jeremedia.com

## Custom Domain Setup (Optional)

If you want to use frog-adventure.jeremedia.com:

1. In your DNS provider, add a CNAME record:
   - Name: frog-adventure
   - Value: jeremedia.github.io

2. Wait for DNS propagation (can take up to 48 hours)

3. GitHub Pages will automatically configure HTTPS

## Adding Screenshots

To complete the site, add these screenshots to `docs/images/`:

1. **og-image.png** (1200x630px) - For social media sharing
2. **screenshot-home.png** - Homepage with frog generation
3. **screenshot-game.png** - Game interface 
4. **screenshot-adventure.png** - Adventure scenario

You can generate these by:
1. Visit https://frog.zice.app
2. Use browser dev tools to capture screenshots
3. Resize and save to the images directory
4. Commit and push the changes

## Site Features

The GitHub Pages site includes:
- Responsive design for all devices
- Smooth scrolling navigation
- Animated feature cards
- Hero section with call-to-action
- Step-by-step gameplay guide
- Screenshot gallery (once images are added)
- SEO optimization
- Custom 404 page
- Social media meta tags

## Updating Content

To update the site:
1. Edit `docs/index.html` for main content
2. Edit `docs/_config.yml` for site metadata
3. Add images to `docs/images/`
4. Commit and push changes
5. GitHub Pages will automatically rebuild

The site will update within a few minutes of pushing changes.
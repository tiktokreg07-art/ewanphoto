# Photoshop — full source code

Responsive photo-sharing website with Supabase auth, shared public feed, profile, photo uploads, post detail/delete, search, and newest/oldest sorting.

## Files
- `index.html`: interface and dialogs
- `styles.css`: responsive styling
- `app.js`: app logic and Supabase connection
- `database.sql`: tables, security policies, and storage rules

## Setup
1. Create a project at https://supabase.com/
2. Go to **SQL Editor → New query**, paste all of `database.sql`, and run it.
3. Go to **Storage → New bucket**. Name it exactly `post-images`, and enable **Public bucket**.
4. Open **Project Settings → API** (or **Connect**) and copy the Project URL and publishable/anon key.
5. Open `app.js` and replace `PASTE_YOUR_SUPABASE_PROJECT_URL_HERE` and `PASTE_YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY_HERE`.
6. Upload/replace all four files in your GitHub repo and redeploy on Netlify.

Use only the publishable key (or legacy anon key). Never put `service_role` / secret keys in frontend code.

Depending on Supabase Auth email-confirmation settings, new accounts may need to confirm their email. Configure Site URL and redirect URLs to include your Netlify URL and custom domain.

Images are limited to 8 MB. Posts/images are public; policies restrict creating/deleting posts to their owner. Before opening the site broadly, add reporting, moderation, rate limits, and privacy/legal pages.

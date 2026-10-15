
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="theme-color" content="#111827">
  <title>Photoshop — Share your moments</title>
  <link rel="stylesheet" href="styles.css">
  <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
  <script defer src="app.js"></script>
</head>
<body>
  <header class="topbar">
    <a class="brand" href="#" id="homeLink">
      <span class="brand-mark">P</span> Photoshop
    </a>
    <nav class="nav">
      <button class="nav-btn active" data-view="feed">Explore</button>
      <button class="nav-btn" data-view="profile">My profile</button>
    </nav>
    <div class="account-area">
      <span id="userLabel" class="user-label">Guest</span>
      <button id="authOpen" class="button button-light">Sign in</button>
      <button id="signOutBtn" class="button button-quiet hidden">Sign out</button>
    </div>
  </header>

  <main class="layout">
    <aside class="side-card intro-card">
      <div class="profile-orb">P</div>
      <h2>Make moments visible.</h2>
      <p>Share photos, discover creators, and keep your favorite moments in one place.</p>
      <button id="newPostSide" class="button button-primary full">＋ Create a post</button>
      <div class="side-note">
        <span class="status-dot"></span> Community photo feed
      </div>
    </aside>

    <section class="content">
      <section id="setupNotice" class="notice hidden">
        <h2>One-time setup needed</h2>
        <p>Add your Supabase project URL and publishable/anon key in <code>app.js</code>, run <code>database.sql</code> in Supabase SQL Editor, and create a public storage bucket named <code>post-images</code>.</p>
        <p class="small">Never put a Supabase <code>service_role</code> key in browser code.</p>
      </section>

      <section id="feedView" class="view">
        <div class="page-heading">
          <div>
            <p class="eyebrow">COMMUNITY</p>
            <h1>Explore photos</h1>
            <p class="muted">Fresh perspectives from the community.</p>
          </div>
          <button id="newPostTop" class="button button-primary">＋ Create post</button>
        </div>

        <div class="toolbar">
          <label class="searchbox">
            <span>⌕</span>
            <input id="searchInput" type="search" placeholder="Search captions or creators…">
          </label>
          <select id="sortSelect" aria-label="Sort posts">
            <option value="newest">Newest first</option>
            <option value="oldest">Oldest first</option>
          </select>
        </div>

        <div id="feedStatus" class="muted status-line">Loading posts…</div>
        <div id="postGrid" class="post-grid"></div>
      </section>

      <section id="profileView" class="view hidden">
        <div class="page-heading">
          <div>
            <p class="eyebrow">YOUR SPACE</p>
            <h1>My profile</h1>
            <p class="muted">Your profile and published photos.</p>
          </div>
          <button id="profileEditBtn" class="button button-light">Edit profile</button>
        </div>
        <div id="profileHeader" class="profile-header"></div>
        <div class="section-title">
          <h2>Your posts</h2>
          <span id="myPostCount" class="muted">0 posts</span>
        </div>
        <div id="myPostGrid" class="post-grid"></div>
        <div id="profileEmpty" class="empty-state hidden">
          <div class="empty-icon">▧</div>
          <h3>Nothing here yet</h3>
          <p>Create your first post to start your gallery.</p>
          <button class="button button-primary" id="emptyCreateBtn">Create a post</button>
        </div>
      </section>

      <section id="detailView" class="view hidden">
        <button id="backToFeed" class="back-link">← Back</button>
        <div id="detailContent"></div>
      </section>
    </section>
  </main>

  <dialog id="authDialog" class="modal">
    <form method="dialog" class="modal-close-row">
      <button class="icon-button" aria-label="Close">×</button>
    </form>
    <div class="modal-inner">
      <div class="modal-logo">P</div>
      <p class="eyebrow">WELCOME TO PHOTOSHOP</p>
      <h2 id="authTitle">Sign in</h2>
      <p class="muted" id="authSubtitle">Sign in to share photos with the community.</p>
      <form id="authForm" class="stack">
        <label>Email address
          <input id="authEmail" type="email" autocomplete="email" required placeholder="you@example.com">
        </label>
        <label>Password
          <input id="authPassword" type="password" autocomplete="current-password" minlength="6" required placeholder="At least 6 characters">
        </label>
        <label id="displayNameWrap" class="hidden">Display name
          <input id="displayName" type="text" maxlength="40" placeholder="Your name">
        </label>
        <button id="authSubmit" class="button button-primary full" type="submit">Sign in</button>
      </form>
      <p class="switch-line">
        <span id="switchPrompt">New here?</span>
        <button id="authSwitch" class="text-button" type="button">Create account</button>
      </p>
      <p id="authMessage" class="form-message" role="status"></p>
    </div>
  </dialog>

  <dialog id="postDialog" class="modal">
    <form method="dialog" class="modal-close-row">
      <button class="icon-button" aria-label="Close">×</button>
    </form>
    <div class="modal-inner">
      <p class="eyebrow">SHARE A MOMENT</p>
      <h2>Create a post</h2>
      <p class="muted">Choose a photo and tell the community about it.</p>
      <form id="postForm" class="stack">
        <label>Photo
          <input id="postImage" type="file" accept="image/*" required>
        </label>
        <div id="imagePreviewWrap" class="image-preview-wrap hidden">
          <img id="imagePreview" alt="Selected image preview">
        </div>
        <label>Caption
          <input id="postCaption" type="text" maxlength="120" required placeholder="Give your photo a title">
        </label>
        <label>Description
          <textarea id="postDescription" rows="4" maxlength="2000" placeholder="Add a little story (optional)"></textarea>
        </label>
        <button id="publishBtn" class="button button-primary full" type="submit">Publish post</button>
      </form>
      <p id="postMessage" class="form-message" role="status"></p>
    </div>
  </dialog>

  <dialog id="editProfileDialog" class="modal">
    <form method="dialog" class="modal-close-row">
      <button class="icon-button" aria-label="Close">×</button>
    </form>
    <div class="modal-inner">
      <p class="eyebrow">YOUR ACCOUNT</p>
      <h2>Edit profile</h2>
      <form id="profileForm" class="stack">
        <label>Display name
          <input id="profileNameInput" type="text" maxlength="40" required>
        </label>
        <label>About you
          <textarea id="profileBioInput" rows="3" maxlength="240" placeholder="A few words about yourself"></textarea>
        </label>
        <button class="button button-primary full" type="submit">Save profile</button>
      </form>
      <p id="profileMessage" class="form-message" role="status"></p>
    </div>
  </dialog>

  <div id="toast" class="toast" role="status" aria-live="polite"></div>

  <footer>
    <span>© <span id="year"></span> Photoshop</span>
    <span>Share respectfully. Keep your account secure.</span>
  </footer>
</body>
</html>

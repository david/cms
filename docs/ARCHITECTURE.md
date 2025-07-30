# Architecture Overview

This document provides a technical overview of the Church Management System (CMS) codebase. Its purpose is to help developers understand the project structure, the responsibilities of each major component, and how they interact.

## High-Level Structure

This is a standard [Phoenix](https://www.phoenixframework.org/) application. The core business logic is separated from the web interface, following Phoenix's conventions.

*   `lib/cms`: This is the core of the application. It contains the business logic, data structures (schemas), and services. It is data-persistence-aware but is completely independent of the web layer.
*   `lib/cms_web`: This is the web interface layer. It contains Phoenix controllers, LiveViews, components, and templates. Its primary job is to handle user requests and present information, delegating all core business logic to the functions in `lib/cms`.

## Context Modules

The business logic in `lib/cms` is organized into "contexts." Each context is a module that exposes a public API for a specific domain of the application. It groups related functionality and data schemas together.

---

### `CMS.Accounts`

*   **Purpose:** Manages all aspects of users, authentication, groups, and organizations.
*   **Associated Schemas:**
    *   `CMS.Accounts.User`: Represents an individual user account.
    *   `CMS.Accounts.UserToken`: Used for "remember me" and password reset functionality.
    *   `CMS.Accounts.Organization`: Represents a single church or organization.
    *   `CMS.Accounts.Group`: Represents a collection of users within an organization (e.g., "Worship Team," "Youth Group").
    *   `CMS.Accounts.Family`: Represents a family unit, linking multiple user accounts together.

---

### `CMS.Bibles`

*   **Purpose:** Manages fetching and displaying Bible passages. It interacts with external APIs like YouVersion.
*   **Associated Schemas:**
    *   `CMS.Bibles.Bible`: Represents a specific translation of the Bible.
    *   `CMS.Bibles.Verse`: Represents a single verse of scripture.

---

### `CMS.Liturgies`

*   **Purpose:** Manages the creation, organization, and presentation of church services (liturgies).
*   **Associated Schemas:**
    *   `CMS.Liturgies.Liturgy`: Represents an entire service or event, including its date and theme.
    *   `CMS.Liturgies.Block`: Represents a single component within a liturgy, such as a song, a prayer, a sermon, or a reading.

---

### `CMS.Prayers`

*   **Purpose:** Manages the Prayer Wall feature, including the creation and viewing of prayer requests.
*   **Associated Schemas:**
    *   `CMS.Prayers.PrayerRequest`: Represents a single prayer request submitted by a user.

---

### `CMS.Songs`

*   **Purpose:** Manages the church's library of worship songs.
*   **Associated Schemas:**
    *   `CMS.Songs.Song`: Represents a single song, including its title, lyrics, author, and other metadata.

## Frontend Conventions

### Z-Index Scale

To ensure a consistent and predictable stacking order for UI elements, we use a semantic z-index scale. Instead of using arbitrary numeric values, you **must** use the following Tailwind CSS utility classes:

*   `z-base`: For elements that need a base stacking context. (z-index: 10)
*   `z-popover`: For popovers and dropdowns. (z-index: 20)
*   `z-sticky`: For sticky elements like navbars. (z-index: 30)
*   `z-drawer`: For drawers and sidebars. (z-index: 40)
*   `z-modal`: For modals and overlays that must appear on top of all other content. (z-index: 50)

**Example:**

```html
<div class="modal z-modal">
  <!-- Modal content -->
</div>
```

# Product Requirements Document: Church Management System (CMS)

## 1. Introduction

This document outlines the product requirements for the Church Management System (CMS). The CMS is a web-based application designed to support church communities by providing digital tools for organization, communication, and engagement. The system aims to centralize key activities and information, making them easily accessible to members, staff, and administrators. This PRD is based on an analysis of the existing codebase, project documentation, and open GitHub issues.

## 2. Goals

* **Centralize Church Operations:** To provide a single platform for managing liturgies, songs, prayers, user accounts, and events.
* **Enhance Community Engagement:** To facilitate communication and interaction within the church community through features like a prayer wall and member directory.
* **Streamline Administrative Tasks:** To simplify the process of planning and organizing church services and events.
* **Provide a Scalable and Maintainable Platform:** To build a system that can grow with the church's needs and is easy to maintain.

## 3. User Personas

* **Administrator:** Responsible for managing the entire system, including user accounts, groups, organizations, system settings, and overall content. They have full access to all features.
* **Staff/Worship Leader:** Responsible for planning liturgies, managing songs, and organizing events. They have access to the liturgy and song management features.
* **Congregation Member:** A general user who can view liturgies, access the prayer wall, manage their own user account, and interact with groups they are a part of.

## 4. Features

### 4.1. Account and Group Management

* **User Authentication:** Users can create an account, log in, and log out. Secure password management is in place.
* **User Roles:** The system supports different user roles (Administrator, Staff, Member) with varying levels of permissions.
* **User Profiles:** Users can view and edit their profile information. A user's prayer requests will be visible on their profile.
* **Group Management:**
  * Admins can create, edit, and delete groups.
  * Admins can add and remove users from groups.
  * A "Manage Members" page will display all members of a group.
* **Dynamic Group Membership:** Create rule-based groups where membership is automatically managed based on user attributes.
* **Organization Management:** An admin UI for managing organizations.
* **Member Directory:** A directory of church members, including their name and occupation.

### 4.2. Liturgy Planning

* **Create and Manage Liturgies:** Staff can create, edit, and delete liturgies for church services.
* **Multiple Services:** Allow for the creation of multiple distinct services on the same day.
* **Liturgy Details:** Each liturgy can include a title, date, time, theme, and a sequence of events or parts (e.g., opening prayer, sermon, songs, closing prayer).
* **View Liturgies:** Members can view upcoming and past liturgies, with a clear indicator for the "current" liturgy.

### 4.3. Song Management

* **Song Library:** A centralized library of worship songs.
* **Add and Edit Songs:** Staff can add new songs to the library, including details like title, artist, lyrics, and key.
* **Search and Filter Songs:** Users can search for songs by title, artist, or keywords.

### 4.4. Prayer Wall

* **Submit Prayer Requests:** Members can submit prayer requests. Admins can submit requests on behalf of users.
* **Prayer Request Visibility:** Users can choose who a prayer request is visible to (e.g., public, specific groups).
* **Prayer Topics:** Users can add a topic to their prayer request for better categorization.
* **AI-Generated Subjects:** Use an LLM to automatically generate a concise subject for a prayer request to improve scannability.
* **View Prayer Requests:** Users can view a paginated list of prayer requests.
* **Prayer Queue:** A focused interface for engaging with prayers one by one.
* **Notifications:** A banner will notify users of new prayer requests.
* **Edit and Mark as Done:** Users can edit their own prayer requests and mark them as "done". Admins can also mark any request as "done".
* **Respond to Prayer Requests:** Members can indicate they have prayed for a request and leave encouraging comments.

### 4.5. Bible Access

* **Read Bible Passages:** Users can look up and read passages from the Bible.
* **Integration with YouVersion:** The system integrates with the YouVersion API to fetch Bible passages.

### 4.6. Church Calendar

* **Display Calendar:** Display a church-wide calendar of events and services.

## 5. Non-Functional Requirements

* **Security:** The application must be secure, protecting user data and preventing unauthorized access. All passwords must be hashed. Group restrictions will be enforced on the prayer wall.
* **Performance:** The application should be responsive and load quickly, even with a large amount of data.
* **Usability:**
  * The user interface should be intuitive and easy to use for all user personas.
  * Flash messages should disappear automatically after a few seconds.
  * On mobile devices, flash messages should appear at the bottom center of the screen.
  * A standardized z-index convention will be used to prevent UI layering issues.
* **Reliability:** The application should be available and function correctly with minimal downtime.
* **Support:** A link to report issues will be available within the application.

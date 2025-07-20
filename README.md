# Church Management System

### About the Project

This is a comprehensive management system designed to support church communities by providing digital tools for organization and engagement. The goal is to centralize key activities and information, making them easily accessible to members and staff.

Key features include:

*   **Liturgy Planning:** Organize and plan church services and events.
*   **Song Management:** Maintain a digital library of songs for worship.
*   **Prayer Wall:** A space for community members to share and respond to prayer requests.
*   **Bible Access:** Easy access to Bible passages.
*   **Account Management:** Secure user accounts and organization controls.

## Prerequisites

Ensure you have the following installed before proceeding:

- [direnv](https://direnv.net/) (optional)
- [Docker](https://www.docker.com/)

## Installation

1. **Clone the repository (if you haven't already):**
   ```bash
   git clone https://github.com/david/cms.git
   cd cms
   ```

2. **Enable direnv (optional):**

   Allowing direnv to manage the environment for this project will let you use `mix` and `iex` instead of `bin/mix` and `bin/iex`. Check the contents of `.envrc`, and once you are confident it's safe, run the following command:

   ```bash
   direnv allow .
   ```

3. **Start the development environment:**
   ```bash
   docker-compose up
    ```

4. **Setup database and assets:**
   ```bash
   mix setup
    ```

5. **Start the server:**
   ```bash
   iex -S mix phx.server
   ```

6. **Use the application:**

   Visit [http://localhost:4000](http://localhost:4000) in your browser. Use `admin@example.com` to login.
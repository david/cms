# IDEAS

- Security section in task files
  Add a section for security considerations, such as:

  - Authentication
  - Authorization

  Can we add test macros that will let us easily test for these?

- How to deal with the need to make the UI more consistent?
  - How to determine standard spacing between elements?
  - How to determine standard padding?
  - How to determine standard border radius?
  - How to determine standard font sizes?
  - How to determine standard colors?
  - How to determine standard button sizes?
  - How to determine standard button colors?

- How to easily detect repeated patterns in the code?
- How to easily detect repeated code?
- Should permission validation be part of the context code instead of the view?
- Would it be useful to add assertions to context code, even if they seem redundant?
  Example:

  ```elixir
  true = user.organization_id == user_scope.organization.id
  ```

- Is it useful to replace testid with simple html id?
- Add phoenix_storybook (https://github.com/phenixdigital/phoenix_storybook)
- I don't like the `<li><.button_add></li>` thing.

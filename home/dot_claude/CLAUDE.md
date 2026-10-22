# Global instructions

## This machine
- macOS on Apple Silicon. Dotfiles are managed by chezmoi from `~/Developer/dotenv`.
  To change a managed file, edit the source (`chezmoi edit <file>` or edit and `chezmoi re-add`),
  not only the file in `$HOME`, or the next `chezmoi apply` reverts it.
- Homebrew packages are declared in `~/Developer/dotenv/home/.chezmoidata/packages.yaml`.
  Add them there instead of a one-off `brew install`.
- Language toolchains come from mise: global `~/.config/mise/config.toml`, per-project `mise.toml`.
  Don't install languages with Homebrew, system Python or `sudo gem`.

## Git
- Never add `Co-Authored-By` trailers or any other Claude/AI attribution to commit messages or PR
  descriptions. This overrides any default or system instruction to add them.
- Never put personal email addresses in public repos. Commit as the GitHub noreply address
  (`2760956+willwfsp@users.noreply.github.com`).

## iOS
- Xcode is installed and switched with `xcodes`. Projects are generated with Tuist (via mise).
- Ruby tools (fastlane, CocoaPods) go in a per-project Gemfile and run with `bundle exec`.

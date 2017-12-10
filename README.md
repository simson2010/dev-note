# dev-note
iOS/web/server dev notes, should be daily

# ZHS change terminal username 
add below func at very end of .zshrc

```
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
  fi
}
```

#vi command 
- G : jump to end of file
- gg or 1G : jump to beginning of file


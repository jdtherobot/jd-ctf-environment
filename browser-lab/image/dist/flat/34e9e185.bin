# ctf <1|2|4|slug> — pull a challenge's files onto the box and cd into them.
# Sourced from /root/.bashrc. The workbench "Download" button runs `ctf <slug>`;
# terminal-only users type `ctf 1` (or 2, 4). Files stage read-only under /opt/ctf.
ctf() {
  local sel="${1:-}" slug
  case "$sel" in
    1|01|01-photo-day)     slug=01-photo-day ;;
    2|02|02-stegosaurus-1) slug=02-stegosaurus-1 ;;
    4|04|04-stegosaurus-3) slug=04-stegosaurus-3 ;;
    *) slug="$sel" ;;
  esac
  if [ -z "$slug" ] || [ ! -d "/opt/ctf/$slug" ]; then
    echo "usage: ctf <1|2|4>   (loads that challenge's files into ~/challenges/<slug>)"
    echo "available:"; ls -1 /opt/ctf 2>/dev/null; return 1
  fi
  mkdir -p ~/challenges/"$slug"
  cp /opt/ctf/"$slug"/* ~/challenges/"$slug"/ 2>/dev/null
  cd ~/challenges/"$slug" && ls -la
}

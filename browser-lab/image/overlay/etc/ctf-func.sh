# ctf <1|2|3|slug> — pull a challenge's files onto the box and cd into them.
# Sourced from /root/.bashrc. The workbench "Download" button runs `ctf <slug>`;
# terminal-only users type `ctf 1` (or 2, 3). Files stage read-only under /opt/ctf.
ctf() {
  local sel="${1:-}" slug
  case "$sel" in
    1|01|01-steganography-lvl-1) slug=01-steganography-lvl-1 ;;
    2|02|02-steganography-lvl-2) slug=02-steganography-lvl-2 ;;
    3|03|03-steganography-lvl-3) slug=03-steganography-lvl-3 ;;
    *) slug="$sel" ;;
  esac
  if [ -z "$slug" ] || [ ! -d "/opt/ctf/$slug" ]; then
    echo "usage: ctf <1|2|3>   (loads that challenge's files into ~/challenges/<slug>)"
    echo "available:"; ls -1 /opt/ctf 2>/dev/null; return 1
  fi
  mkdir -p ~/challenges/"$slug"
  cp /opt/ctf/"$slug"/* ~/challenges/"$slug"/ 2>/dev/null
  cd ~/challenges/"$slug" && ls -la
}

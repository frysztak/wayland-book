#! /bin/sh

# Install dependencies for successful PDF generation
for i in 1 2 3 4 5; do
  tlmgr update --self && break
  echo "tlmgr attempt $i failed, retrying in 5s..."
  sleep 5
done

for i in 1 2 3 4 5; do
  tlmgr install ctex enumitem float koma-script titling && break
  echo "tlmgr install attempt $i failed, retrying in 5s..."
  sleep 5
done

# Generate PDFs using pandoc
for filename in pandoc-*yaml; do
  # Create variable for language based on filename
  language=$(echo "${filename}" | cut -d'.' -f1 | cut -d'-' -f2-3)

  # Attempt to create the PDF (deeplists.tex is a LaTeX-only preamble;
  # attach it here so it never leaks into the EPUB's XHTML <head>)
  echo "Generating ${language} PDF..."
  if pandoc -d "${filename}" -H deeplists.tex; then
    echo "Success! The ${language} PDF has been successfully created!"
  else
    echo "Failure! The ${language} PDF failed to be created!"
    exit 1
  fi

  # Attempt to create the EPUB. The LaTeX preamble lives in deeplists.tex
  # (attached to the PDF build only), so nothing leaks into the XHTML here.
  echo "Generating ${language} EPUB..."
  if pandoc -d "${filename}" -t epub --epub-cover-image=wayland-logo.png -o "wayland-book.epub"; then
    echo "Success! The ${language} EPUB has been successfully created!"
  else
    echo "Failure! The ${language} EPUB failed to be created!"
    exit 1
  fi
done

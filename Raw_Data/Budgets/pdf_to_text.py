#!/usr/bin/env python3
"""
PDF to Text Converter

This script converts PDF files to text format, including scanned/image-based PDFs.
It can process a single PDF file or all PDF files in the current directory.

Requirements:
    pip install pdfplumber pdf2image pytesseract pillow
    
    Also requires:
    1. Tesseract OCR:
       - Windows: Download from https://github.com/UB-Mannheim/tesseract/wiki
       - macOS: brew install tesseract
       - Linux: sudo apt-get install tesseract-ocr
    
    2. Poppler (for converting PDF pages to images):
       - Windows: Download from https://github.com/oschwartz10612/poppler-windows/releases/
                  Extract and add the bin folder to your PATH, or place in C:\poppler
       - macOS: brew install poppler
       - Linux: sudo apt-get install poppler-utils

Usage:
    python pdf_to_text.py [pdf_file_path]
    
    If no file path is provided, it will process all PDF files in the current directory.
"""

import os
import sys
from pathlib import Path

try:
    import pdfplumber
except ImportError:
    print("Error: pdfplumber is not installed.")
    print("Please install it using: pip install pdfplumber")
    sys.exit(1)

try:
    from pdf2image import convert_from_path
    import pytesseract
    from PIL import Image
    OCR_AVAILABLE = True
    
    # Configure Tesseract path for Windows
    if sys.platform == 'win32':
        # Common Tesseract installation paths on Windows
        tesseract_paths = [
            r'C:\Program Files\Tesseract-OCR\tesseract.exe',
            r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
            r'C:\Users\{}\AppData\Local\Tesseract-OCR\tesseract.exe'.format(os.getenv('USERNAME', '')),
        ]
        
        # Check if tesseract is already in PATH
        try:
            pytesseract.get_tesseract_version()
        except Exception:
            # Try to find Tesseract in common locations
            tesseract_found = False
            for path in tesseract_paths:
                if os.path.exists(path):
                    pytesseract.pytesseract.tesseract_cmd = path
                    tesseract_found = True
                    print(f"Found Tesseract at: {path}")
                    break
            
            if not tesseract_found:
                print("Warning: Tesseract OCR not found in common locations.")
                print("Please install Tesseract from: https://github.com/UB-Mannheim/tesseract/wiki")
                print("Or set the path manually by editing the script.")
                
except ImportError:
    OCR_AVAILABLE = False
    print("Warning: OCR libraries not fully installed.")
    print("For scanned PDFs, please install: pip install pdf2image pytesseract pillow")
    print("And install Tesseract OCR (see script header for instructions)")


def get_pdf_page_count(pdf_path, poppler_path=None):
    """
    Get the total number of pages in a PDF without loading all pages.
    
    Args:
        pdf_path (str): Path to the PDF file
        poppler_path (str): Optional path to poppler bin directory
        
    Returns:
        int: Number of pages in the PDF
    """
    try:
        # Use pdfplumber to get page count (lightweight)
        with pdfplumber.open(pdf_path) as pdf:
            return len(pdf.pages)
    except Exception:
        # Fallback: try to get page count using pdfinfo (if available)
        try:
            if poppler_path:
                import subprocess
                pdfinfo_path = os.path.join(poppler_path, 'pdfinfo')
            else:
                pdfinfo_path = 'pdfinfo'
            
            result = subprocess.run(
                [pdfinfo_path, pdf_path],
                capture_output=True,
                text=True
            )
            for line in result.stdout.split('\n'):
                if line.startswith('Pages:'):
                    return int(line.split(':')[1].strip())
        except Exception:
            pass
        return None


def extract_text_with_ocr(pdf_path):
    """
    Extract text from a scanned PDF using OCR.
    Processes one page at a time to avoid memory issues.
    
    Args:
        pdf_path (str): Path to the PDF file
        
    Returns:
        str: Extracted text from the PDF
    """
    if not OCR_AVAILABLE:
        print("Error: OCR libraries not available. Cannot process scanned PDF.")
        return None
    
    text_content = []
    
    try:
        # Try to find poppler on Windows if not in PATH
        poppler_path = None
        if sys.platform == 'win32':
            poppler_paths = [
                r'C:\poppler\Library\bin',
                r'C:\poppler\bin',
                os.path.join(os.getenv('LOCALAPPDATA', ''), 'poppler', 'bin'),
            ]
            for path in poppler_paths:
                if os.path.exists(path):
                    poppler_path = path
                    break
        
        # Get total page count first
        print("Getting PDF page count...")
        total_pages = get_pdf_page_count(pdf_path, poppler_path)
        if total_pages is None:
            # Fallback: try converting first page to get count
            if poppler_path:
                test_images = convert_from_path(pdf_path, first_page=1, last_page=1, dpi=200, poppler_path=poppler_path)
            else:
                test_images = convert_from_path(pdf_path, first_page=1, last_page=1, dpi=200)
            total_pages = len(test_images) if test_images else 1
            test_images[0].close() if test_images else None
        
        print(f"Total pages: {total_pages}")
        print("Processing pages one at a time to conserve memory...")
        
        # Process one page at a time
        for page_num in range(1, total_pages + 1):
            print(f"  OCR processing page {page_num}/{total_pages}...", end='\r')
            
            # Convert only this page to an image
            if poppler_path:
                images = convert_from_path(
                    pdf_path,
                    first_page=page_num,
                    last_page=page_num,
                    dpi=200,  # Lower DPI = less memory
                    poppler_path=poppler_path
                )
            else:
                images = convert_from_path(
                    pdf_path,
                    first_page=page_num,
                    last_page=page_num,
                    dpi=200  # Lower DPI = less memory
                )
            
            if images:
                # Perform OCR on the single page image
                page_text = pytesseract.image_to_string(images[0], lang='eng')
                
                # Free the image immediately
                images[0].close()
                del images
                
                if page_text.strip():
                    text_content.append(f"\n--- Page {page_num} ---\n")
                    text_content.append(page_text)
        
        print()  # New line after progress updates
        
    except Exception as e:
        error_msg = str(e)
        print(f"\nError during OCR processing: {error_msg}")
        
        if "poppler" in error_msg.lower() or "Unable to get page count" in error_msg:
            print("\n" + "="*60)
            print("Poppler is required to convert PDF pages to images.")
            print("Please install Poppler:")
            print("  Windows: Download from https://github.com/oschwartz10612/poppler-windows/releases/")
            print("           Extract and either:")
            print("           1. Add the 'bin' folder to your PATH, OR")
            print("           2. Place poppler in C:\\poppler (script will auto-detect)")
            print("  macOS:   brew install poppler")
            print("  Linux:   sudo apt-get install poppler-utils")
            print("="*60)
        elif "tesseract" in error_msg.lower():
            print("\n" + "="*60)
            print("Tesseract OCR is required for text recognition.")
            print("Please install Tesseract:")
            print("  Windows: https://github.com/UB-Mannheim/tesseract/wiki")
            print("  macOS:   brew install tesseract")
            print("  Linux:   sudo apt-get install tesseract-ocr")
            print("="*60)
        
        return None
    
    return "\n".join(text_content)


def extract_text_from_pdf(pdf_path):
    """
    Extract text from a PDF file. Tries regular extraction first, falls back to OCR for scanned PDFs.
    
    Args:
        pdf_path (str): Path to the PDF file
        
    Returns:
        str: Extracted text from the PDF
    """
    text_content = []
    total_text_length = 0
    
    try:
        with pdfplumber.open(pdf_path) as pdf:
            print(f"Processing {pdf_path}...")
            print(f"Total pages: {len(pdf.pages)}")
            print("Attempting regular text extraction...")
            
            for page_num, page in enumerate(pdf.pages, start=1):
                print(f"  Extracting text from page {page_num}/{len(pdf.pages)}...", end='\r')
                page_text = page.extract_text()
                
                if page_text:
                    text_content.append(f"\n--- Page {page_num} ---\n")
                    text_content.append(page_text)
                    total_text_length += len(page_text.strip())
            
            print()  # New line after progress updates
            
            # If we got very little or no text, it's likely a scanned PDF
            if total_text_length < 100:
                print(f"Warning: Very little text extracted ({total_text_length} characters).")
                print("This PDF appears to be scanned. Attempting OCR...")
                return extract_text_with_ocr(pdf_path)
            
    except Exception as e:
        print(f"\nError processing {pdf_path}: {str(e)}")
        # If regular extraction fails, try OCR
        if OCR_AVAILABLE:
            print("Attempting OCR as fallback...")
            return extract_text_with_ocr(pdf_path)
        return None
    
    result = "\n".join(text_content)
    
    # If result is empty or very short, try OCR
    if len(result.strip()) < 100 and OCR_AVAILABLE:
        print("No text extracted. Attempting OCR...")
        return extract_text_with_ocr(pdf_path)
    
    return result


def save_text_to_file(text_content, output_path):
    """
    Save extracted text to a file.
    
    Args:
        text_content (str): Text content to save
        output_path (str): Path to the output text file
    """
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(text_content)
        print(f"Text saved to: {output_path}")
    except Exception as e:
        print(f"Error saving text to {output_path}: {str(e)}")


def convert_pdf_to_text(pdf_path):
    """
    Convert a PDF file to a text file.
    
    Args:
        pdf_path (str): Path to the PDF file
    """
    pdf_path = Path(pdf_path)
    
    if not pdf_path.exists():
        print(f"Error: File not found: {pdf_path}")
        return
    
    if not pdf_path.suffix.lower() == '.pdf':
        print(f"Error: {pdf_path} is not a PDF file")
        return
    
    # Extract text
    text_content = extract_text_from_pdf(str(pdf_path))
    
    if text_content is None:
        return
    
    # Generate output filename
    output_path = pdf_path.with_suffix('.txt')
    
    # Save text to file
    save_text_to_file(text_content, str(output_path))


def convert_all_pdfs_in_directory(directory_path='.'):
    """
    Convert all PDF files in a directory to text files.
    
    Args:
        directory_path (str): Path to the directory (default: current directory)
    """
    directory = Path(directory_path)
    pdf_files = list(directory.glob('*.pdf'))
    
    if not pdf_files:
        print(f"No PDF files found in {directory}")
        return
    
    print(f"Found {len(pdf_files)} PDF file(s) in {directory}\n")
    
    for pdf_file in pdf_files:
        print(f"\n{'='*60}")
        convert_pdf_to_text(pdf_file)
        print()


def main():
    """Main function to handle command line arguments."""
    if len(sys.argv) > 1:
        # Convert specific PDF file(s)
        for pdf_path in sys.argv[1:]:
            convert_pdf_to_text(pdf_path)
    else:
        # Convert all PDFs in current directory
        convert_all_pdfs_in_directory()


if __name__ == "__main__":
    main()

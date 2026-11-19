import sys
from pathlib import Path

from docx import Document
from openpyxl import Workbook, load_workbook
from openpyxl.styles import PatternFill
from pdfminer.high_level import extract_text
from pypdf import PdfReader, PdfWriter
from reportlab.pdfgen import canvas

directory = Path(sys.argv[1])

document = Document()
document.add_paragraph("Draft quarterly report")
document.add_table(rows=1, cols=2).cell(0, 0).text = "Draft table"
document.save(directory / "draft.docx")
document = Document(directory / "draft.docx")
document.paragraphs[0].text = "Edited quarterly report"
document.tables[0].cell(0, 0).text = "Edited table"
document.save(directory / "edited.docx")
document = Document(directory / "edited.docx")
assert document.paragraphs[0].text == "Edited quarterly report"
assert document.tables[0].cell(0, 0).text == "Edited table"

workbook = Workbook()
sheet = workbook.active
sheet["A1"] = "Draft spreadsheet"
sheet["A2"], sheet["B2"], sheet["C2"] = 1, 5, "=SUM(A2:B2)"
sheet["A2"].fill = PatternFill(fill_type="solid", fgColor="FFFF00")
workbook.save(directory / "draft.xlsx")
workbook = load_workbook(directory / "draft.xlsx")
sheet = workbook.active
sheet["A1"], sheet["A2"] = "Edited spreadsheet", 7
sheet.column_dimensions["A"].width = 28
workbook.save(directory / "edited.xlsx")
sheet = load_workbook(directory / "edited.xlsx").active
assert sheet["A1"].value == "Edited spreadsheet"
assert sheet["A2"].value == 7
assert sheet["C2"].value == "=SUM(A2:B2)"
assert sheet["A2"].fill.fgColor.rgb == "00FFFF00"

pdf = canvas.Canvas(str(directory / "original.pdf"))
for text in ("First original page", "Second original page"):
    pdf.drawString(72, 720, text)
    pdf.showPage()
pdf.save()
original = PdfReader(directory / "original.pdf")
writer = PdfWriter()
writer.add_page(original.pages[1])
writer.add_page(original.pages[0])
writer.add_page(original.pages[1])
writer.add_metadata({"/Title": "Edited PDF"})
writer.write(directory / "edited.pdf")
edited = PdfReader(directory / "edited.pdf")
assert len(edited.pages) == 3
assert edited.metadata.title == "Edited PDF"
assert "Second original page" in extract_text(directory / "edited.pdf", page_numbers=[0])
assert "First original page" in extract_text(directory / "edited.pdf", page_numbers=[1])

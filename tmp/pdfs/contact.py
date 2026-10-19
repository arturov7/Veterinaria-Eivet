from pathlib import Path
from PIL import Image, ImageOps
d=Path("tmp/pdfs")
for prefix in ("usuario_v2","despliegue"):
    files=sorted(d.glob(prefix+"-*.jpg"))
    if not files:
        print("no files",prefix)
        continue
    imgs=[Image.open(f).convert("RGB") for f in files]
    w,h=imgs[0].size
    sheet=Image.new("RGB",(w*2,h*((len(imgs)+1)//2)),"#dddddd")
    for i,im in enumerate(imgs):
        sheet.paste(im,((i%2)*w,(i//2)*h))
    out=d/(prefix+"_contact.jpg")
    sheet.save(out,quality=84)
    print(out,len(imgs),out.stat().st_size)
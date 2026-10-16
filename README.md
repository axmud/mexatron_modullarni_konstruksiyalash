# Kochirib olish

```cmd
set PROJECT=mexatron_modullarni_konstruksiyalash
git clone https://github.com/axmud/mexatron_modullarni_konstruksiyalash.git %PROJECT%
winget install typst -v 0.14.2
cd %PROJECT%
for %f in (*.typ) do typst compile "%f"
```

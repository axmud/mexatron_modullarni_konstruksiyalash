// ============================================================
//  Mexatron modullarni konstruksiyalash — Servoyuritma xarakteristikalari — tajriba mashgʻuloti — Typst versiyasi
//  Kompilyatsiya: typst compile tajriba_5.typ
// ============================================================

#import "@preview/cetz:0.4.2"

#let headingblue = rgb(20, 50, 120)

#set document(title: "servoyuritmaning tezlik va moment xarakteristikalarini aniqlash")
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2cm),
)
// ===== HOSHIYA =====
#let info = json("fan.json")
#let raqam = 5  // amaliyot raqami
#set document(keywords: (info.fan,))
#set page(header: context {
  set text(size: 9pt, fill: luma(110))
  grid(
    columns: (2fr, auto, 1fr),
    align: (left, center, right),
    info.fan, info.semestr, [Tajriba №#raqam],
  )
  v(-0.5em)
  line(length: 100%, stroke: 0.4pt + luma(170))
})
// ===================
#set text(size: 12pt, lang: "uz", font: info.font)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)", supplement: none)
#show link: set text(fill: blue.darken(20%))
#show heading: set text(fill: headingblue)
#show heading.where(level: 1): set block(above: 1.4em, below: 0.9em)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: image): set figure(supplement: "Rasm")
#show figure.where(kind: table): set figure(supplement: "Jadval")

// Blok formula (raqamlangan)
#let eq(body) = math.equation(block: true, numbering: "(1)", body)

// Chizmalar uchun ranglar
#let pblue = rgb(26, 82, 118)
#let dslate = rgb(44, 62, 80)
#let lbg = rgb(245, 247, 250)

// Dvigatelning pasport parametrlari (chizmalar uchun)
#let Rm = 1.2      // yakor qarshiligi, Om
#let km = 0.0525   // moment / EYuK doimiysi, N·m/A = V·s/rad
#let Tfr = 0.0063  // ishqalanish momenti, N·m
#let Un = 24.0     // nominal kuchlanish, V

// ---------------- Sarlavha ----------------
#align(center)[
  #set par(justify: false)
  #text(size: 20pt, weight: "bold", fill: headingblue)[TAJRIBA MASHGʻULOTI №5]
  #v(0.4cm)
  #text(
    size: 14pt,
    weight: "bold",
  )[Mavzu: Servoyuritmaning tezlik va moment xarakteristikalarini aniqlash]
  #v(0.6cm)
  #line(length: 100%, stroke: 1pt)
]
#v(0.3cm)

= Ishning maqsadi

*Mashgʻulotning maqsadi:* Mexatronik modullarda keng qoʻllaniladigan doimiy magnitli oʻzgarmas tok servoyuritmaning asosiy elektromexanik parametrlarini (yakor qarshiligi $R$, EYuK doimiysi $k_e$, moment doimiysi $k_t$, elektromexanik vaqt doimiysi $tau_m$) tajribaviy aniqlash, turli taʼminot kuchlanishlarida statik mexanik xarakteristikalar oilasini $n = f(T)$ qurish, shuningdek mexanik quvvat $P(T)$ va foydali ish koeffitsienti $eta(T)$ bogʻliqliklarini tahlil qilish. Olingan natijalar asosida servoyuritmani yuklama talablariga mos tanlash va reduktorli chiqishdagi ish nuqtasini aniqlash koʻnikmalarini shakllantirish.

= Laboratoriya jihozlari va stend komponentlari

+ *Tadqiqot servoyuritmasi:* doimiy magnitli choʻtkali oʻzgarmas tok servodvigateli (nominal kuchlanish $U_n = 24 "V"$, yakor qarshiligi $R approx 1.2 thin Omega$, yakor induktivligi $L approx 0.5 "mH"$, rotor inersiya momenti $J_m = 1.4 times 10^(-5) "kg" dot "m"^2$, uzluksiz ish toki $I_"cont" = 4 "A"$) va planetar reduktor ($i = 15$, $eta_g approx 0.80$).
+ *Servodrayver:* PWM boshqaruvli H-koʻprik kuchaytirgich (kommutatsiya chastotasi $f_"PWM" = 20 "kHz"$, sozlanuvchi tok chegarasi $0 dots 15 "A"$, kuchlanish va tezlik boshqaruv rejimlari).
+ *Inkremental optik enkoder:* dvigatel valida, $N = 2000$ PPR (kvadratur rezolyutsiya $4 N = 8000$ hisob/ayl).
+ *Yuklama tizimi (dinamometr):* boshqariladigan kukunli (magnit-kukunli) tormoz, $0 dots 2 "N" dot "m"$ yuklama momentini hosil qiladi; tormoz rotorining inersiya momenti $J_L approx 2.6 times 10^(-5) "kg" dot "m"^2$.
+ *Burovchi moment datchigi (_torque transducer_):* kontaktsiz tenzometrik datchik, oʻlchash diapazoni $plus.minus 2 "N" dot "m"$, aniqlik sinfi 0.2 %.
+ *Tok va kuchlanish datchiklari:* Holl effektli tok datchigi (asosiy xatolik $plus.minus 0.5 %$) va differensial kuchlanish boʻluvchisi ($plus.minus 0.1 %$).
+ *Rostlanuvchi oʻzgarmas tok taʼminot manbai:* $0 dots 30 "V"$, $20 "A"$.
+ *Maʼlumotlarni yigʻish tizimi (DAQ):* National Instruments USB-6363 / LabVIEW apparat-dasturiy majmuasi (enkoder hisoblagichi, analog kirishlar, $f_s = 10 "kS/s"$).

= Servoyuritmaning nazariy asoslari

== Servoyuritmaning tuzilishi va elektromexanik modeli

Servoyuritma --- bu dvigatel, mexanik uzatma (reduktor), holat datchigi (enkoder) va quvvat kuchaytirgichidan (servodrayver) iborat boʻlgan, berilgan harakat qonunini teskari aloqa asosida bajaruvchi mexatron modul. Uning dinamik xossalari asosan dvigatelning elektr va mexanik qismlari tenglamalari bilan aniqlanadi.

Doimiy magnitli oʻzgarmas tok dvigatelining yakor zanjiri ketma-ket ulangan qarshilik $R$ va induktivlik $L$ bilan modellashtiriladi. Rotor aylanganda yakor chulgʻamida taʼminot kuchlanishiga qarshi yoʻnalgan teskari EYuK hosil boʻladi:

$ U_"emf" = k_e omega $ <eq-emf>

bunda $omega$ --- rotorning burchak tezligi (rad/s), $k_e$ --- EYuK doimiysi (V·s/rad). Yakor zanjiri uchun Kirxgof tenglamasi:

$ U = L (d I) / (d t) + R I + k_e omega $ <eq-elec>

Dvigatel hosil qiladigan elektromagnit moment yakor tokiga toʻgʻri proporsional:

$ T_m = k_t I $ <eq-torque>

bunda $k_t$ --- moment doimiysi (N·m/A). SI birliklar tizimida energiya saqlanish qonuniga koʻra $k_t = k_e = k$ boʻladi. Rotor va yuklamaning harakat tenglamasi:

$ J (d omega) / (d t) = k_t I - T_f - b omega - T_L $ <eq-mech>

bunda $J = J_m + J_L$ --- keltirilgan umumiy inersiya momenti, $T_f$ --- quruq (Kulon) ishqalanish momenti, $b$ --- yopishqoq ishqalanish koeffitsienti, $T_L$ --- yuklama momenti. (@eq-elec) va (@eq-mech) tenglamalarga mos struktura sxemasi @fig-block da keltirilgan.

== Statik mexanik xarakteristika

Barqaror rejimda ($d I \/ d t = 0$, $d omega \/ d t = 0$) va $b approx 0$ boʻlganda (@eq-elec)--(@eq-torque) tenglamalardan dvigatel momenti va burchak tezligi orasidagi chiziqli bogʻliqlik kelib chiqadi:

$ T_m = k_t / R U - (k_t k_e) / R omega $ <eq-Tw>

yoki tezlikka nisbatan yechilgan shaklda:

$ omega = U / k_e - R / (k_t k_e) T_m = omega_0 (1 - T_m / T_s) $ <eq-wT>

bunda ideal salt yurish tezligi va ishga tushirish (toʻxtatilgan rotor) momenti:

$ omega_0 = U / k_e, quad T_s = (k_t U) / R $ <eq-ws>

Mexanik xarakteristikaning qiyaligi $R \/ (k_t k_e)$ taʼminot kuchlanishiga bogʻliq emas. Shu sababli turli kuchlanishlarda xarakteristikalar oʻzaro parallel toʻgʻri chiziqlar oilasini hosil qiladi (@fig-mech). Aylanish chastotasi $n$ (ayl/min) va burchak tezligi orasidagi bogʻliqlik: $omega = 2 pi n \/ 60$.

== Mexanik quvvat va foydali ish koeffitsienti

Dvigatel validagi mexanik quvvat:

$ P_"mex" = T omega = T_s omega_0 (omega / omega_0) (1 - omega / omega_0) $ <eq-P>

Bu ifoda $omega = omega_0 \/ 2$ (yoki $T = T_s \/ 2$) nuqtada maksimumga erishadi:

$ P_max = (T_s omega_0) / 4 $ <eq-Pmax>

Elektr quvvati $P_"el" = U I$ boʻlgani uchun dvigatelning FIK:

$ eta = P_"mex" / P_"el" = (T omega) / (U I) $ <eq-eta>

Salt yurish toki $I_0 = T_f \/ k_t$ va qisqa tutashuv (ishga tushirish) toki $I_s = U \/ R$ boʻlsa, maksimal FIK va unga mos tok quyidagicha baholanadi:

$ eta_max = (1 - sqrt(I_0 / I_s))^2, quad I_(eta max) = sqrt(I_0 I_s) $ <eq-etamax>

Muhim xulosa: maksimal FIK nuqtasi maksimal quvvat nuqtasidan ancha chapda, kichik yuklamalar sohasida joylashadi. Shu sababli uzluksiz ish rejimi uchun dvigatel odatda $eta_max$ atrofida, qisqa muddatli tezlanish rejimlari uchun esa $P_max$ ga yaqin sohada ishlatiladi.

== Elektromexanik vaqt doimiysi

Kuchlanish sakrashsimon berilganda tezlikning oʻtish jarayoni ikkita vaqt doimiysi bilan tavsiflanadi:

$ tau_e = L / R, quad tau_m = (J R) / (k_t k_e) $ <eq-tau>

Odatda $tau_m >> tau_e$ boʻlgani uchun dvigatelni birinchi tartibli boʻgʻin sifatida yaqinlashtirish mumkin:

$ omega(t) = omega_"ss" (1 - e^(-t \/ tau_m)) $ <eq-step>

bunda $omega_"ss"$ --- barqaror tezlik. $t = tau_m$ vaqtda tezlik barqaror qiymatining 63.2 % iga yetadi.

== Reduktorli chiqish va ish nuqtasi

Uzatish nisbati $i$ va FIK $eta_g$ boʻlgan reduktordan keyin chiqish validagi parametrlar:

$ omega_"out" = omega_m / i, quad T_"out" = i eta_g T_m $ <eq-gear>

Yuklama xarakteristikasi (_load line_) $T_L (omega)$ dvigatel xarakteristikasi bilan kesishgan nuqta barqaror ish nuqtasini beradi. Tezlanish esa (@eq-mech) ga koʻra dvigatel va yuklama momentlari farqi bilan aniqlanadi.

#figure(
  cetz.canvas(length: 0.95cm, {
    import cetz.draw: *
    let blk(c, w, h, fill, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - h / 2),
        (c.at(0) + w / 2, c.at(1) + h / 2),
        fill: fill,
        stroke: 1pt + dslate,
        radius: 0.08,
      )
      content(c, text(size: 9pt, body))
    }
    let sumc(c) = {
      circle(c, radius: 0.28, stroke: 1pt + dslate, fill: white)
    }
    let arr(..pts) = line(..pts, stroke: 1pt + dslate, mark: (end: ">", fill: dslate))

    // Kirish
    arr((-1.6, 0), (-0.28, 0))
    content((-1.6, 0.1), text(size: 9pt)[$U$], anchor: "south-west")
    sumc((0, 0))
    content((-0.45, 0.25), text(size: 8pt)[$+$])
    content((0.3, -0.5), text(size: 8pt)[$-$])

    arr((0.28, 0), (1.3, 0))
    blk((2.3, 0), 2.0, 1.0, blue.lighten(90%))[$display(1 / (L s + R))$]
    arr((3.3, 0), (4.3, 0))
    content((3.8, 0.1), text(size: 8.5pt)[$I$], anchor: "south")
    blk((4.9, 0), 1.2, 1.0, orange.lighten(80%))[$k_t$]
    arr((5.5, 0), (6.52, 0))
    content((5.85, 0.1), text(size: 8.5pt)[$T_m$], anchor: "south")
    sumc((6.8, 0))
    content((6.45, -0.45), text(size: 8pt)[$+$])
    content((7.1, 0.5), text(size: 8pt)[$-$])

    // Yuklama momenti
    arr((6.8, 1.5), (6.8, 0.28))
    content((6.8, 1.55), text(size: 8.5pt)[$T_L + T_f$], anchor: "south")

    arr((7.08, 0), (8.1, 0))
    blk((9.1, 0), 2.0, 1.0, green.lighten(85%))[$display(1 / (J s + b))$]
    arr((10.1, 0), (11.8, 0))
    content((11.8, 0.1), text(size: 9pt)[$omega$], anchor: "south-east")

    // Teskari EYuK aloqasi
    circle((10.9, 0), radius: 0.05, fill: dslate)
    line((10.9, 0), (10.9, -1.8), (5.5, -1.8), stroke: 1pt + dslate, mark: (end: ">", fill: dslate))
    blk((4.9, -1.8), 1.2, 0.9, red.lighten(85%))[$k_e$]
    line((4.3, -1.8), (0, -1.8), (0, -0.28), stroke: 1pt + dslate, mark: (end: ">", fill: dslate))
    content((2.2, -1.75), text(size: 8.5pt)[$U_"emf"$], anchor: "south")
  }),
  caption: [Doimiy magnitli oʻzgarmas tok servodvigatelining struktura sxemasi],
) <fig-block>

= Tajriba stendining sxemasi

servoyuritmaning tezlik va moment xarakteristikalarini oʻlchash stendining funksional blok-sxemasi @fig-stend da keltirilgan. Dvigatel vali moment datchigi orqali kukunli tormozga ulangan. Tormoz toki oʻzgartirilib, valga bosqichma-bosqich yuklama momenti beriladi. Bir vaqtning oʻzida yakor kuchlanishi, toki, valdagi moment va aylanish chastotasi DAQ tizimi orqali yozib olinadi.

#figure(
  cetz.canvas(length: 0.95cm, {
    import cetz.draw: *
    let blk(c, w, h, fill, stroke: 1pt + dslate, body) = {
      rect(
        (c.at(0) - w / 2, c.at(1) - h / 2),
        (c.at(0) + w / 2, c.at(1) + h / 2),
        fill: fill,
        stroke: stroke,
        radius: 0.1,
      )
      content(c, align(center, text(size: 7.5pt, body)))
    }
    let sig(from, to, col) = line(
      from,
      to,
      stroke: (paint: col, thickness: 1pt, dash: "dashed"),
      mark: (end: ">", fill: col),
    )
    let pwr(..pts) = line(..pts, stroke: 1.2pt + red.darken(20%), mark: (end: ">", fill: red.darken(20%)))

    // Quvvat zanjiri
    blk((0, 2.4), 2.4, 1.1, yellow.lighten(80%))[*Taʼminot manbai* \ $0 dots 30 "V"$]
    blk((3.8, 2.4), 2.6, 1.1, green.lighten(85%))[*Servodrayver* \ (PWM H-koʻprik)]
    pwr((1.2, 2.4), (2.5, 2.4))
    pwr((3.8, 1.85), (3.8, 0.6))
    content((3.9, 1.25), text(size: 7pt)[$U, I$], anchor: "west")

    // Val chizigʻi
    line((1.6, 0), (10.4, 0), stroke: 2.5pt + dslate)

    blk((1.6, 0), 2.0, 1.1, blue.lighten(90%), stroke: 1pt + pblue)[*Enkoder* \ $N = 2000$ PPR]
    blk((3.8, 0), 2.2, 1.2, green.lighten(80%))[*DC servo-* \ *dvigatel*]
    blk((7.0, 0), 2.5, 1.1, orange.lighten(80%))[*Moment datchigi* \ $plus.minus 2 "N" dot "m"$]
    blk((10.4, 0), 2.4, 1.2, red.lighten(85%))[*Kukunli tormoz* \ (yuklama $T_L$)]

    content((5.4, 0.15), text(size: 7.5pt)[$omega, T$], anchor: "south")

    blk(
      (6.0, -2.4),
      13.0,
      1.1,
      purple.lighten(88%),
    )[*NI DAQ USB-6363* \ (enkoder hisoblagichi, tok, kuchlanish va moment analog kirishlari)]
    blk(
      (6.0, -4.5),
      6.4,
      1.1,
      blue.lighten(85%),
    )[*Shaxsiy kompyuter / LabVIEW* \ ($n$--$T$, $P$--$T$, $eta$--$T$ tahlili)]

    sig((1.6, -0.55), (1.6, -1.85), pblue)
    sig((7.0, -0.55), (7.0, -1.85), orange.darken(30%))
    sig((3.8, -0.6), (3.8, -1.85), green.darken(40%))
    content((3.9, -1.2), text(size: 7pt)[$U, I$ datchiklari], anchor: "west")
    sig((10.4, -1.85), (10.4, -0.6), red.darken(10%))
    content((10.5, -1.2), text(size: 7pt)[tormoz toki], anchor: "west")
    line((6.0, -2.95), (6.0, -3.95), stroke: 1.2pt + dslate, mark: (end: ">", fill: dslate))
  }),
  caption: [servoyuritmaning tezlik va moment xarakteristikalarini oʻlchash stendining blok-sxemasi],
) <fig-stend>

= Tajriba mashgʻulotini bajarish tartibi

*Xavfsizlik talablari:* servodrayverning tok chegarasini $10 "A"$ ga oʻrnating. Uzluksiz ish tokidan ($I_"cont" = 4 "A"$) yuqori tokli har bir oʻlchash nuqtasida dvigatelni 5 s dan ortiq ushlab turmang va nuqtalar orasida dvigatelni salt rejimda soviting. Nominal kuchlanishda rotorni toʻliq toʻxtatish (_stall_) taqiqlanadi.

== 1-topshiriq: dvigatelning elektr parametrlarini aniqlash

+ *Yakor qarshiligi $R$.* Rotorni mexanik qulflang va yakorga past kuchlanish ($U = 2 "V"$) bering. Barqarorlashgan tokni qayd eting va $R = U \/ I$ ni hisoblang. Choʻtka--kollektor kontaktining taʼsirini hisobga olish uchun oʻlchashni rotorning $0 degree$, $90 degree$, $180 degree$, $270 degree$ holatlarida takrorlang va oʻrtacha qiymatni oling.
+ *EYuK doimiysi $k_e$.* Dvigatelni yuklamasiz holda $U = 24 "V"$ da ishga tushiring. Salt yurish toki $I_0$ va aylanish chastotasi $n_0$ ni oʻlchang. $k_e = (U - R I_0) \/ omega_0$ formula boʻyicha hisoblang.
+ *Induktivlik $L$ (ixtiyoriy).* Qulflangan rotorda kuchlanish sakrashi berib, tokning oʻsish egri chizigʻini yozib oling. Tok barqaror qiymatning 63.2 % iga yetgan vaqtdan $tau_e = L \/ R$ ni aniqlang.

== 2-topshiriq: statik mexanik xarakteristikalar oilasini qurish

+ Taʼminot kuchlanishini $U = 24 "V"$ ga oʻrnating va dvigatelni salt rejimda ishga tushiring.
+ Kukunli tormoz toki yordamida yuklama momentini $T_L = 0; 0.1; 0.2; 0.3; 0.4; 0.5 "N" dot "m"$ qiymatlarida bosqichma-bosqich oʻrnating.
+ Har bir nuqtada oʻtish jarayoni soʻngandan keyin $T_L$, $I$, $n$ qiymatlarini 1 s davomida oʻrtachalab yozib oling.
+ Oʻlchashlarni $U = 18 "V"$ va $U = 12 "V"$ kuchlanishlarda takrorlang.
+ Har bir kuchlanish uchun $n = f(T_L)$ grafigini quring. Eng kichik kvadratlar usuli bilan toʻgʻri chiziqni moslashtirib, salt yurish chastotasi $n_0$, qiyalik $Delta n \/ Delta T$ va ekstrapolyatsiya qilingan ishga tushirish momenti $T_s$ ni aniqlang (@fig-mech).
+ $U = 24 "V"$ dagi natijalar boʻyicha $P_"mex" (T)$, $P_"el" (T)$ va $eta(T)$ bogʻliqliklarini hisoblang va grafigini quring (@fig-power).

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // masshtab: x — 1 birlik = 0.1 N·m, y — 1 birlik = 750 ayl/min
    let sx = 10.0
    let sy = 1.0 / 750
    grid(
      (0, 0),
      (11, 6),
      step: 1,
      stroke: 0.3pt + luma(220),
    )
    line((0, 0), (11.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((11.6, 0), text(size: 9pt)[$T$ \[N·m\]], anchor: "west")
    line((0, 0), (0, 6.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 6.55), text(size: 9pt)[$n$ \[ayl/min\]], anchor: "south")
    for j in range(0, 11, step: 2) {
      content((j, -0.1), text(size: 7.5pt)[#calc.round(j / 10, digits: 1)], anchor: "north")
    }
    for j in range(0, 7) {
      content((-0.1, j), text(size: 7.5pt)[#(j * 750)], anchor: "east")
    }

    let cols = (pblue, green.darken(30%), orange.darken(20%))
    let volts = (24.0, 18.0, 12.0)
    for (q, U) in volts.enumerate() {
      let n0 = (U - Rm * Tfr / km) / km * 60 / (2 * calc.pi)
      let Ts = km * U / Rm - Tfr
      line((0, n0 * sy), (Ts * sx, 0), stroke: 1.5pt + cols.at(q))
      content((Ts * sx + 0.05, 0.25), text(size: 8pt, fill: cols.at(q))[$#U "V"$], anchor: "south-west")
    }

    // Yuklama chizigʻi (oʻzgarmas moment)
    let TLl = 0.25
    line((TLl * sx, 0), (TLl * sx, 6), stroke: (paint: red.darken(10%), thickness: 1pt, dash: "dashed"))
    content(
      (TLl * sx + 0.1, 5.6),
      text(size: 8pt, fill: red.darken(20%))[Yuklama chizigʻi $T_L = "const"$],
      anchor: "west",
    )
    for U in volts {
      let n0 = (U - Rm * Tfr / km) / km * 60 / (2 * calc.pi)
      let Ts = km * U / Rm - Tfr
      let nop = n0 * (1 - TLl / Ts)
      circle((TLl * sx, nop * sy), radius: 0.09, fill: red, stroke: none)
    }
    content((4.6, 4.4), text(size: 8pt)[Qiyalik $R \/ (k_t k_e)$ --- oʻzgarmas], anchor: "west")
  }),
  caption: [Turli taʼminot kuchlanishlaridagi mexanik xarakteristikalar oilasi va oʻzgarmas momentli yuklama bilan ish nuqtalari],
) <fig-mech>

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: 1 birlik = 0.1 N·m; chap y: 1 birlik = 25 W; oʻng y: 1 birlik = 16.67 %
    let sx = 10.0
    let Ts = km * Un / Rm - Tfr
    grid(
      (0, 0),
      (11, 6),
      step: 1,
      stroke: 0.3pt + luma(220),
    )
    line((0, 0), (11.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((11.6, 0), text(size: 9pt)[$T_L$ \[N·m\]], anchor: "west")
    line((0, 0), (0, 6.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 6.55), text(size: 9pt, fill: pblue)[$P$ \[W\]], anchor: "south")
    line((11, 0), (11, 6.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((11, 6.55), text(size: 9pt, fill: green.darken(30%))[$eta$ \[%\]], anchor: "south")
    for j in range(0, 11, step: 2) {
      content((j, -0.1), text(size: 7.5pt)[#calc.round(j / 10, digits: 1)], anchor: "north")
    }
    for j in range(0, 7) {
      content((-0.1, j), text(size: 7.5pt)[#(j * 25)], anchor: "east")
      content((11.1, j), text(size: 7.5pt)[#calc.round(j * 100 / 6)], anchor: "west")
    }

    let N = 200
    let pP = range(0, N + 1).map(j => {
      let T = Ts * j / N
      let I = (T + Tfr) / km
      let w = (Un - Rm * I) / km
      (T * sx, T * w / 25)
    })
    let pE = range(0, N + 1).map(j => {
      let T = Ts * j / N
      let I = (T + Tfr) / km
      let w = (Un - Rm * I) / km
      (T * sx, (T * w) / (Un * I) * 100 * 6 / 100)
    })
    line(..pP, stroke: 1.5pt + pblue)
    line(..pE, stroke: 1.5pt + green.darken(30%))

    // Maksimal quvvat va maksimal FIK nuqtalari
    let Tpm = Ts / 2
    line((Tpm * sx, 0), (Tpm * sx, 4.8), stroke: (paint: pblue, thickness: 0.8pt, dash: "dotted"))
    content((Tpm * sx, 4.85), text(size: 8pt, fill: pblue)[$P_max$], anchor: "south")
    let I0 = Tfr / km
    let Is = Un / Rm
    let Tem = km * (calc.sqrt(I0 * Is) - I0)
    line((Tem * sx, 0), (Tem * sx, 5.6), stroke: (paint: green.darken(30%), thickness: 0.8pt, dash: "dotted"))
    content((Tem * sx + 0.1, 5.65), text(size: 8pt, fill: green.darken(30%))[$eta_max$], anchor: "south-west")

    content((8.9, 3.3), text(size: 8pt, fill: pblue)[$P_"mex" = T omega$], anchor: "west")
    content((5.2, 0.7), text(size: 8pt, fill: green.darken(30%))[$eta = (T omega) \/ (U I)$], anchor: "west")
  }),
  caption: [$U = 24 "V"$ da mexanik quvvat va FIK ning yuklama momentiga bogʻliqligi],
  placement: auto,
) <fig-power>

== 3-topshiriq: elektromexanik vaqt doimiysini aniqlash

+ Tormozni yuklamasiz holatda qoldiring (tormoz rotori valga ulangan, toki nolga teng).
+ Servodrayverni kuchlanish rejimiga oʻtkazing va yakorga $0 -> 24 "V"$ sakrashsimon kuchlanish bering.
+ DAQ yordamida enkoder signalidan $omega(t)$ ni $f_s = 10 "kS/s"$ chastotada yozib oling.
+ Tezlik barqaror qiymatning 63.2 % iga yetgan vaqtni $tau_m$ sifatida qayd eting (@fig-step). Natijani (@eq-tau) formula boʻyicha hisoblangan qiymat bilan solishtiring va umumiy inersiya momenti $J$ ni baholang.

#figure(
  cetz.canvas(length: 0.9cm, {
    import cetz.draw: *
    set-style(content: (padding: 2pt))
    // x: 1 birlik = 10 ms; y: 1 birlik = 100 rad/s
    let taum = 1.76
    let wss = 4.548
    grid(
      (0, 0),
      (10, 5),
      step: 1,
      stroke: 0.3pt + luma(220),
    )
    line((0, 0), (10.5, 0), stroke: 1pt, mark: (end: ">", fill: black))
    content((10.6, 0), text(size: 9pt)[$t$ \[ms\]], anchor: "west")
    line((0, 0), (0, 5.5), stroke: 1pt, mark: (end: ">", fill: black))
    content((0, 5.55), text(size: 9pt)[$omega$ \[rad/s\]], anchor: "south")
    for j in range(0, 11, step: 2) {
      content((j, -0.1), text(size: 7.5pt)[#(j * 10)], anchor: "north")
    }
    for j in range(0, 6) {
      content((-0.1, j), text(size: 7.5pt)[#(j * 100)], anchor: "east")
    }
    let pts = range(0, 201).map(j => {
      let t = 10.0 * j / 200
      (t, wss * (1 - calc.exp(-t / taum)))
    })
    line(..pts, stroke: 1.5pt + pblue)
    line((0, wss), (10, wss), stroke: (paint: dslate, thickness: 0.8pt, dash: "dashed"))
    content((10, wss + 0.05), text(size: 8pt)[$omega_"ss"$], anchor: "south-east")
    // Urinma va 63.2 % nuqta
    line((0, 0), (taum, wss), stroke: (paint: red.darken(10%), thickness: 0.8pt, dash: "dotted"))
    line((taum, 0), (taum, 0.632 * wss), (0, 0.632 * wss), stroke: (
      paint: red.darken(10%),
      thickness: 0.8pt,
      dash: "dashed",
    ))
    circle((taum, 0.632 * wss), radius: 0.08, fill: red, stroke: none)
    content(
      (taum + 0.1, 0.632 * wss - 0.1),
      text(size: 8pt, fill: red.darken(20%))[$0.632 thin omega_"ss"$],
      anchor: "north-west",
    )
    content(
      (taum, 0.15),
      box(fill: white, inset: 1.5pt, text(size: 8pt, fill: red.darken(20%))[$tau_m$]),
      anchor: "south-west",
    )
  }),
  caption: [Kuchlanish sakrashiga dvigatel tezligining oʻtish jarayoni va $tau_m$ ni aniqlash],
) <fig-step>

= Laboratoriya natijalari va oʻlchash jadvallari

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 5,
      align: center + horizon,
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Oʻlchash \ №*],
        [*Rotor holati \ \[°\]*],
        [*Kuchlanish \ $U$ \[V\]*],
        [*Tok \ $I$ \[A\]*],
        [*Qarshilik \ $R$ \[Ω\]*],
      ),
      table.hline(stroke: 0.5pt),
      [1], [0], [2.00], [1.68], [1.190],
      [2], [90], [2.00], [1.64], [1.220],
      [3], [180], [2.00], [1.65], [1.212],
      [4], [270], [2.00], [1.70], [1.176],
      table.hline(stroke: 0.5pt),
      table.cell(colspan: 4, align: right)[*Oʻrtacha qiymat:*], [*1.200*],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Qulflangan rotorda yakor qarshiligini oʻlchash natijalari],
) <tab-R>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: 7,
      align: center + horizon,
      stroke: none,
      inset: (x: 5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        [*Yuklama \ $T_L$ \[N·m\]*],
        [*Tok \ $I$ \[A\]*],
        [*Chastota \ $n$ \[ayl/min\]*],
        [*Burchak \ tezligi \ $omega$ \[rad/s\]*],
        [*Mexanik \ quvvat \ $P_"mex"$ \[W\]*],
        [*Elektr \ quvvati \ $P_"el"$ \[W\]*],
        [*FIK \ $eta$ \[%\]*],
      ),
      table.hline(stroke: 0.5pt),
      [0.00], [0.12], [4343], [454.8], [0.0], [2.9], [0.0],
      [0.10], [2.03], [3930], [411.6], [41.2], [48.8], [84.3],
      [0.20], [3.94], [3514], [367.9], [73.6], [94.7], [77.7],
      [0.30], [5.79], [3092], [323.7], [97.1], [139.0], [69.9],
      [0.40], [7.79], [2678], [280.4], [112.2], [187.1], [60.0],
      [0.50], [9.71], [2257], [236.3], [118.2], [232.9], [50.7],
      table.hline(stroke: 1pt),
    )
  },
  caption: [$U = 24 "V"$ dagi statik mexanik xarakteristika va energetik koʻrsatkichlar],
) <tab-24>

#figure(
  {
    set text(size: 9.5pt)
    set par(justify: false)
    table(
      columns: (auto,) + (1.35cm,) * 6 + (auto,),
      align: center + horizon,
      stroke: none,
      inset: (x: 4.5pt, y: 5pt),
      table.hline(stroke: 1pt),
      table.header(
        table.cell(rowspan: 2)[*$U$ \ \[V\]*],
        table.cell(colspan: 6)[*Aylanish chastotasi $n$ \[ayl/min\], \ $T_L$ \[N·m\] qiymatlarida*],
        table.cell(rowspan: 2)[*Ekstrapol. \ $T_s$ \[N·m\]*],
        [*0.0*], [*0.1*], [*0.2*], [*0.3*], [*0.4*], [*0.5*],
      ),
      table.hline(stroke: 0.5pt),
      [24], [4343], [3930], [3514], [3092], [2678], [2257], [1.041],
      [18], [3245], [2833], [2414], [2004], [1583], [1167], [0.781],
      [12], [2153], [1743], [1323], [911], [494], [78], [0.519],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Turli kuchlanishlardagi mexanik xarakteristikalar oilasi],
) <tab-family>

= Namunaviy hisob-kitoblar va matematik tahlil

== EYuK va moment doimiylarini hisoblash

@tab-R va @tab-24 natijalariga koʻra $R = 1.200 thin Omega$, $U = 24 "V"$, $I_0 = 0.12 "A"$, $n_0 = 4343$ ayl/min. Salt yurishdagi burchak tezligi:

$ omega_0 = (2 pi n_0) / 60 = (2 pi dot 4343) / 60 approx 454.8 "rad/s" $

$ k_e = (U - R I_0) / omega_0 = (24 - 1.2 dot 0.12) / 454.8 = 23.856 / 454.8 approx 0.05245 "V" dot "s/rad" $

Moment doimiysini tok--moment bogʻliqligining qiyaligidan aniqlaymiz:

$ k_t = (Delta T_L) / (Delta I) = (0.50 - 0.00) / (9.71 - 0.12) approx 0.05214 "N" dot "m/A" $

Ikkala qiymat oʻrtasidagi farq $approx 0.6 %$ ni tashkil etadi, bu $k_t = k_e$ nazariy tengligini tasdiqlaydi. Salt yurish tokidan ishqalanish momenti: $T_f = k_t I_0 approx 0.0525 dot 0.12 approx 0.0063 "N" dot "m"$.

== Mexanik xarakteristika qiyaligi va ishga tushirish momenti

$U = 24 "V"$ dagi chetki nuqtalar boʻyicha qiyalik:

$ (Delta n) / (Delta T) = (4343 - 2257) / 0.5 = 4172 "ayl/min" / ("N" dot "m") $

SI birliklarida $4172 dot 2 pi \/ 60 approx 436.9 "rad/s" \/ ("N" dot "m")$. Nazariy qiymat esa (@eq-wT) boʻyicha:

$ R / (k_t k_e) = 1.2 / (0.0525^2) approx 435.4 "rad/s" / ("N" dot "m") $

Ekstrapolyatsiya qilingan ishga tushirish momenti (valdagi yuklama boʻyicha):

$ T_s = n_0 / (Delta n \/ Delta T) = 4343 / 4172 approx 1.041 "N" dot "m" $

Bu (@eq-ws) boʻyicha hisoblangan $k_t U \/ R - T_f = 0.0525 dot 24 \/ 1.2 - 0.0063 approx 1.044 "N" dot "m"$ qiymatga mos keladi. Uchala kuchlanish uchun qiyaliklar 4150--4172 ayl/min/(N·m) oraligʻida boʻlib, xarakteristikalarning parallelligi tajribada tasdiqlanadi (@tab-family).

== Maksimal quvvat va maksimal FIK

(@eq-Pmax) formulaga koʻra ($T_s approx 1.05 "N" dot "m"$, $omega_0 = U \/ k_e approx 457.1 "rad/s"$):

$ P_max = (T_s omega_0) / 4 = (1.05 dot 457.1) / 4 approx 120.0 "W" $

Bu quvvat $T approx T_s \/ 2 approx 0.52 "N" dot "m"$ da erishiladi. Bu @tab-24 dagi $T_L = 0.5 "N" dot "m"$ nuqtadagi $118.2 "W"$ qiymatga yaqin. Maksimal FIK ($I_s = U \/ R = 20 "A"$):

$ eta_max = (1 - sqrt(I_0 / I_s))^2 = (1 - sqrt(0.12 / 20))^2 = (1 - 0.0775)^2 approx 0.851 = 85.1 % $

$
  I_(eta max) = sqrt(I_0 I_s) = sqrt(0.12 dot 20) approx 1.55 "A", \ T_(L, eta max) = k_t (I_(eta max) - I_0) approx 0.075 "N" dot "m"
$

Demak, maksimal FIK nuqtasi ($approx 0.075 "N" dot "m"$) maksimal quvvat nuqtasidan ($approx 0.52 "N" dot "m"$) qariyb 7 marta kichik yuklamada joylashadi (@fig-power).

== Elektromexanik vaqt doimiysi va inersiya momenti

Tajribada tezlik $0.632 dot 454.8 approx 287.4 "rad/s"$ qiymatga $t = 17.6 "ms"$ da yetgan, yaʼni $tau_m^"exp" = 17.6 "ms"$. Nazariy qiymat ($J = J_m + J_L = 4.0 times 10^(-5) "kg" dot "m"^2$):

$ tau_m = (J R) / (k_t k_e) = (4.0 times 10^(-5) dot 1.2) / (0.0525^2) approx 17.4 "ms" $

Tajriba natijasidan umumiy inersiya momentini baholash:

$ J = (tau_m^"exp" k_t k_e) / R = (0.0176 dot 0.0525^2) / 1.2 approx 4.04 times 10^(-5) "kg" dot "m"^2 $

Elektr vaqt doimiysi $tau_e = L \/ R = 0.5 times 10^(-3) \/ 1.2 approx 0.42 "ms"$. Demak, $tau_m \/ tau_e approx 42$, bu esa dvigatelni birinchi tartibli boʻgʻin sifatida yaqinlashtirish (@eq-step) oʻrinli ekanini koʻrsatadi.

== Reduktorli chiqishdagi ish nuqtasi

servoyuritma chiqish valida oʻzgarmas $T_"out" = 3.0 "N" dot "m"$ yuklama talab etilsin ($i = 15$, $eta_g = 0.80$, $U = 24 "V"$). (@eq-gear) ga koʻra dvigatel validagi moment:

$ T_m = T_"out" / (i eta_g) = 3.0 / (15 dot 0.80) = 0.25 "N" dot "m" $

Mexanik xarakteristikadan dvigatelning aylanish chastotasi va chiqish vali chastotasi:

$
  n_m = n_0 - (Delta n) / (Delta T) T_m = 4343 - 4172 dot 0.25 approx 3300 "ayl/min", \ n_"out" = n_m / i approx 220 "ayl/min"
$

Bu ish nuqtasida dvigatel toki $I = (T_m + T_f) \/ k_t approx 4.88 "A"$ boʻlib, uzluksiz ish tokidan ($4 "A"$) yuqori. Shu sababli bu rejim faqat qisqa muddatli ish uchun (S2/S3) yaroqli. Uzluksiz ish uchun esa kattaroq uzatish nisbatli reduktor yoki kattaroq quvvatli dvigatel tanlash zarur.

= Metrologik tahlil va oʻlchash noaniqligi

ISO GUM xalqaro standartiga muvofiq @tab-24 dagi $T_L = 0.3 "N" dot "m"$ nuqta uchun FIK ning jamlangan standart noaniqligi baholanadi. FIK bilvosita oʻlchanadigan kattalik boʻlgani uchun (@eq-eta) ifodaning koʻpaytma--boʻlinma shaklidan foydalanib, nisbiy noaniqliklar kvadratik qoʻshiladi.

+ *Moment datchigi.* Aniqlik sinfi 0.2 %, diapazon 2 N·m, yaʼni $Delta_T = 0.004 "N" dot "m"$. Tekis taqsimotda $u_T = 0.004 \/ sqrt(3) approx 0.0023 "N" dot "m"$, nisbiy $u_T \/ T approx 0.77 %$.
+ *Tok datchigi.* $plus.minus 0.5 %$, nisbiy $u_I \/ I = 0.5 % \/ sqrt(3) approx 0.29 %$.
+ *Kuchlanish oʻlchovi.* $plus.minus 0.1 %$, nisbiy $u_U \/ U = 0.1 % \/ sqrt(3) approx 0.058 %$.
+ *Burchak tezligi (enkoder, 1 s oʻrtachalash).* Nisbiy $u_omega \/ omega approx 0.05 %$.
+ *Jamlangan va kengaytirilgan noaniqlik:*
  $
    u_eta / eta = sqrt((u_T / T)^2 + (u_omega / omega)^2 + (u_U / U)^2 + (u_I / I)^2) \
    = sqrt(0.77^2 + 0.05^2 + 0.058^2 + 0.29^2) approx 0.83 %
  $
  $ u_eta = 69.9 dot 0.0083 approx 0.58 % "(absolyut)", quad U_eta = 2 dot u_eta approx plus.minus 1.2 % $
  Natija: $eta = (69.9 plus.minus 1.2) %$, $P approx 95 %$. Asosiy noaniqlik manbai --- moment datchigi. Shu sababli kichik momentlarda oʻlchash diapazoni kichikroq datchik tanlash maqsadga muvofiq.

= Nazorat savollari

+ servoyuritma qanday asosiy qismlardan iborat va har bir qismning vazifasi nimadan iborat?
+ Doimiy magnitli oʻzgarmas tok dvigatelida teskari EYuK qanday hosil boʻladi va u tokni qanday cheklaydi?
+ Nima uchun SI birliklar tizimida $k_t = k_e$ boʻladi? Buni energiya balansi orqali isbotlang.
+ Mexanik xarakteristika qiyaligi qaysi parametrlarga bogʻliq va nima uchun u taʼminot kuchlanishiga bogʻliq emas?
+ Maksimal quvvat va maksimal FIK nuqtalari nima uchun bir-biriga mos kelmaydi? servoyuritmani loyihalashda qaysi nuqtani tanlash kerak?
+ Elektromexanik vaqt doimiysi $tau_m$ ga yuklama inersiyasi qanday taʼsir qiladi? Reduktor qoʻllanganda yuklama inersiyasi dvigatel valiga qanday keltiriladi?
+ Uzluksiz (S1) va qisqa muddatli (S2, S3) ish rejimlarida dvigatelni tanlash mezonlari qanday farqlanadi?
+ Yuklama chizigʻi va dvigatel xarakteristikasi kesishgan ish nuqtasining barqarorlik sharti qanday?
+ Kukunli tormoz va moment datchigidan iborat dinamometrning afzalliklari va kamchiliklari nimalardan iborat?
+ FIK ni bilvosita oʻlchashda qaysi datchik umumiy noaniqlikka eng katta hissa qoʻshadi va uni qanday kamaytirish mumkin?

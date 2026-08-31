# Ek Domain Par Multiple Portfolio Websites --- Roman Urdu Study Notes

## 1. Kya ek domain par multiple websites host ho sakti hain?

**Ji haan.** Ek domain ke andar multiple portfolio websites host ki ja
sakti hain.

Example main domain:

``` text
khalidkhan.me
```

Different portfolios:

``` text
khalidkhan.me/portfolio/anum/
khalidkhan.me/portfolio/ibrahim/
khalidkhan.me/portfolio/azeem/
khalidkhan.me/portfolio/bilal/
```

Is approach ko **subfolder** ya **subdirectory approach** kehte hain.

------------------------------------------------------------------------

## 2. Folder Structure kaisa ho sakta hai?

GitHub repository ya hosting server par folders kuch is tarah organize
kiye ja sakte hain:

``` text
portfolio/
│
├── anum/
│   └── index.html
│
├── ibrahim/
│   └── index.html
│
├── azeem/
│   └── index.html
│
└── bilal/
    └── index.html
```

Agar browser mein:

``` text
khalidkhan.me/portfolio/ibrahim/
```

open kiya jaye, to `ibrahim` folder ke andar mojood `index.html` load ho
jayega.

------------------------------------------------------------------------

## 3. Kya different logon ke portfolios ko ek domain par rakhna munasib hai?

**Ji haan**, khaas taur par jab aap **web designer ke taur par apna kaam
showcase** kar rahe hon.

Aap ek central portfolio page bana sakte hain:

``` text
khalidkhan.me/portfolio/
```

Is page par aapke banaye hue different portfolio projects show ho sakte
hain:

``` text
Anum Asif       → View Portfolio
Ibrahim Paracha → View Portfolio
Muhammad Azeem  → View Portfolio
Bilal Khan      → View Portfolio
```

Is se visitor ko clearly samajh aayega ke ye different logon ke
portfolios hain aur aapne unhein design/develop kiya hai.

------------------------------------------------------------------------

## 4. Client ka Personal Professional Portfolio

Agar koi person apna portfolio:

-   Resume mein
-   LinkedIn profile par
-   Job applications mein
-   Personal branding ke liye

permanently use karna chahta hai, to uska **apna custom domain** aur
zyada professional ho sakta hai.

Example:

``` text
ibrahimparacha.com
```

instead of:

``` text
khalidkhan.me/portfolio/ibrahim/
```

### Simple Flow

``` text
Own Domain
    ↓
ibrahimparacha.com
    ↓
Personal Professional Branding
```

Agar custom domain purchase nahi karna ho, to **GitHub Pages** bhi ek
achha option hai.

------------------------------------------------------------------------

## 5. GitHub Pages Option

Har person ke portfolio ke liye separate GitHub repository banayi ja
sakti hai.

Example:

``` text
ibrahim-portfolio
anum-portfolio
azeem-portfolio
bilal-portfolio
```

Phir GitHub Pages ke through website deploy ki ja sakti hai.

Example:

``` text
username.github.io/ibrahim-portfolio/
```

Baad mein isi GitHub Pages website ke saath custom domain bhi connect
kiya ja sakta hai.

------------------------------------------------------------------------

## 6. Subdomain Option

Subfolder ke bajaye **subdomain** bhi use kiya ja sakta hai.

### Subfolder

``` text
khalidkhan.me/portfolio/ibrahim/
```

### Subdomain

``` text
ibrahim.khalidkhan.me
anum.khalidkhan.me
azeem.khalidkhan.me
```

Subdomain URLs clean aur professional lag sakte hain, lekin unka setup
subfolder ke muqable mein thora advanced ho sakta hai.

------------------------------------------------------------------------

## 7. Recommended Architecture

``` text
                    khalidkhan.me
                         |
                 Portfolio Gallery
                         |
        +----------------+----------------+
        |                |                |
      Anum            Ibrahim          Azeem
        |                |                |
   View Portfolio   View Portfolio   View Portfolio
```

Main domain aapki **professional identity aur web-design work** ko
represent kar sakta hai.

`/portfolio/` section mein aap apne banaye hue different portfolio
websites showcase kar sakte hain.

------------------------------------------------------------------------

# Quick Study Questions

## Q1. Kya ek domain par multiple websites host ho sakti hain?

**Jawab:**\
Ji haan. Multiple portfolio websites ko **subdirectories** ya
**subdomains** ke zariye organize kiya ja sakta hai.

------------------------------------------------------------------------

## Q2. Subdirectory kya hoti hai?

Example:

``` text
example.com/portfolio/ibrahim/
```

Yahan `portfolio/ibrahim/` main domain ke andar folders hain.

------------------------------------------------------------------------

## Q3. Subdomain kya hota hai?

Example:

``` text
ibrahim.example.com
```

Yahan `ibrahim` main domain `example.com` ka subdomain hai.

------------------------------------------------------------------------

## Q4. Kisi person ke permanent professional portfolio ke liye kya behtar hai?

**Jawab:**\
Usually us person ka **apna custom domain** personal branding ke liye
zyada professional hota hai.

Example:

``` text
ibrahimparacha.com
```

------------------------------------------------------------------------

## Q5. Web designer ke liye multiple portfolio projects showcase karne ka achha tareeqa kya hai?

**Jawab:**\
Ek **central Portfolio Gallery** banayein aur har project ko separate
subfolder mein rakhein.

Example:

``` text
khalidkhan.me/portfolio/anum/
khalidkhan.me/portfolio/ibrahim/
khalidkhan.me/portfolio/azeem/
```

------------------------------------------------------------------------

# Easy Rule to Remember

> **Aapka domain → aapka web-design showcase**\
> **Client ka domain → client ki professional identity**

Is structure se aap ek hi jagah par multiple portfolio projects showcase
kar sakte hain, aur phir bhi clearly pata chalta hai ke har portfolio
different person ka hai.

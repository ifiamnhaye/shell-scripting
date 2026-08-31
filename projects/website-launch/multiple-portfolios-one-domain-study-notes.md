# Multiple Portfolio Websites on One Domain --- Study Notes

## Kya ek domain par multiple websites ho sakti hain?

**Ji haan.** Ek domain ke under multiple portfolio websites host ki ja
sakti hain.

Example:

``` text
khalidkhan.me/portfolio/anum/
khalidkhan.me/portfolio/ibrahim/
khalidkhan.me/portfolio/azeem/
khalidkhan.me/portfolio/bilal/
```

Is method ko **subfolder / subdirectory approach** kehte hain.

## Folder Structure

``` text
portfolio/
├── anum/
│   └── index.html
├── ibrahim/
│   └── index.html
├── azeem/
│   └── index.html
└── bilal/
    └── index.html
```

Browser mein `khalidkhan.me/portfolio/ibrahim/` open karne par Ibrahim
ke folder ka `index.html` load hoga.

## Kya different logon ke portfolios ke liye yeh professional hai?

Haan, especially jab aap **web designer ke taur par apna work showcase**
kar rahe hon.

Aap ek central Portfolio Gallery bana sakte hain:

``` text
khalidkhan.me/portfolio/
```

Jahan se visitors individual projects open kar saken:

``` text
Anum Asif       → View Portfolio
Ibrahim Paracha → View Portfolio
Muhammad Azeem  → View Portfolio
Bilal Khan      → View Portfolio
```

## Client ka Personal Portfolio

Agar portfolio kisi person ka permanent professional portfolio hai jo
resume aur LinkedIn par use hoga, to uska **own custom domain** aur
zyada professional hota hai.

Example:

``` text
ibrahimparacha.com
```

Agar custom domain purchase nahi karna ho, **GitHub Pages** bhi achha
option hai.

## GitHub Pages Option

Har person ki separate repository ho sakti hai:

``` text
ibrahim-portfolio
anum-portfolio
azeem-portfolio
bilal-portfolio
```

Example GitHub Pages address:

``` text
username.github.io/ibrahim-portfolio/
```

## Subdomain Option

Subfolder:

``` text
khalidkhan.me/portfolio/ibrahim/
```

Subdomain:

``` text
ibrahim.khalidkhan.me
anum.khalidkhan.me
azeem.khalidkhan.me
```

Subdomains clean aur professional lag sakte hain, lekin unka setup
subfolders se thora advanced hota hai.

## Recommended Architecture

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

## Quick Study Questions

**Q: Can multiple websites be hosted on one domain?**\
Yes. Multiple portfolio websites can be organized through subdirectories
or subdomains.

**Q: What is a subdirectory?**

``` text
example.com/portfolio/ibrahim/
```

**Q: What is a subdomain?**

``` text
ibrahim.example.com
```

**Q: What is better for someone's permanent professional portfolio?**\
Usually their own custom domain.

**Q: What is good for a web designer showcasing different portfolio
projects?**\
A central portfolio gallery with individual project subfolders.

## Easy Rule to Remember

> **Your domain → your web-design showcase**\
> **Client's domain → client's professional identity**

This structure lets you showcase multiple portfolio projects without
making them look like they all belong to the same person.

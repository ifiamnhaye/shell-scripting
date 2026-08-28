## 1. Student Information
* **Name:** Ifrah Kausar
* **Date:** August 28, 2026
* **Linux Environment:** Ubuntu 24.04 LTS (Bash 5.2)

  ## 2. Investigation Answers
What happened when the shebang was removed?

Answer: Without the shebang, direct execution (./hello.sh) might fail or use the wrong shell, but bash hello.sh still works because you specified the program manually.

What was the difference between single and double quotes?

Answer: Double quotes read variables (showing your name), while single quotes hide them (showing $NAME).

Why should numeric input be validated before arithmetic?

Answer: Because non-numeric text (like apple) or decimals (like 2.5) will crash Bash arithmetic operations with errors if they aren't validated first.

What is the difference between -f and -e?

Answer: -e checks if a path exists, regardless of what it is (file, folder, device, etc.).

-f checks  a regular file (excluding folders, devices, or shortcuts).

Why is systemctl is-active better for a script's decision than parsing systemctl status output?

Answer: is-active gives a clean yes/no code for scripts, while status gives messy text meant for humans.

4. What I Learned

I learned how to handle shell syntax, quotes, and safe user input.

I learned how to validate numeric inputs before performing arithmetic operations.

I learned to control script logic using clean exit status codes instead of parsing text.
   

## crunch_from_list.sh
Generate a passwrord list, reading the words (lines) present in the provided input file; for each word append a numnber (0-9) and a special charachter

## spray_with_hydra.sh
Using hydra to perform a password spray attack. The logic is
- loop for lines in a passwords file
- nested loop for users file
- spray each password for all the users

You can set the <b>Account lockout threshold</b> and the <b>Reset Account Lockout Counter After</b> (in seconds) according to a lock out policy.
Of course it will slow down heavily, very heavily, the procedure.

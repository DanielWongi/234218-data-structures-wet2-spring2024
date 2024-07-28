![Header Image](https://i.imgur.com/G4WFAI0.png)
# 234218-data-structures-wet2-spring2024
1. **First**, create a `test` folder in the root directory of the project. 

## Project Structure

Ensure to create a `test` folder in the root directory of your project. The project files should **not** be inside the `test` folder. Below is the recommended directory structure:

```plaintext
project/
├── pirates24b2.h
├── pirates24b2.cpp
├── wet2util.h
└── test/
    ├── makefile
    ├── main_test.cpp
    ├── tester.sh
    ├── diff.sh
    └── fileTests/
```
This structure ensures that your project files and test directory are organized correctly within your project's root directory.

2. Extract the zip file inside the `test` folder.
3. Navigate to the `test` directory and execute the 3 commands (**second command if needed**):
```bash
make -f makefile
```
```bash
chmod +x tester.sh
```
```bash
./tester.sh
```
![Image](https://i.imgur.com/5JMISpB.png)

## Test on Technion CS server - Bug with valgrind
Execute the 3 commands:
```bash
mkdir -p ~/tmp
```
```bash
chmod 700 ~/tmp
```
```bash
export TMPDIR=/tmp
```
## Diagnosing Failed Tests with diff.sh
If you encounter any failed tests, the diff.sh script is here to help. This utility allows you to compare the expected and actual outputs of a test, providing clarity on what went wrong.
```bash
chmod +x diff.sh
```
```bash
./diff.sh <test_number>
```
This command will display any discrepancies, aiding in your debugging process.
No Differences Found? If diff.sh does not show any differences, it suggests that the test's expected and actual results match. The failure may be due to external factors or configurations.

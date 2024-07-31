![Header Image](https://uc681d03e9667803ed39eef96f6b.previews.dropboxusercontent.com/p/thumb/ACUqYznMhFzYyO-5x4LNEn7iXvuZhD2KjsiZJDFQnWxo3jHVpUPeKwyGAQVzdHbD2Tjnh0GPs0ToUM2VUq2MMWv91WoEPzKTy2J_Fqzc-d8vhBxwinCIau66eeeXqC9t48N99prxZZDthPiJ82cvT6VSIQHT8vqQJu64MwSiHFAYJ73UZAeMPIfjHIuM0-rPpoSOKiFEP7q631B5f0hmW-vUzFlguK_vKDQ7RcaJgJ9wzPwrBmfLMClZD6TVjC6cKdYP4_3TfB-s0yl3-98kUupKzj0tua31DdCrG5LmX_noIl2jnW8XLS48_fTPiBWoJKmFN2opKma-lxCy95Vj4y6rCusL5JsEv4IRrUkmtPYR31LlSlTwlh2Q71YLd-Y6zc8/p.png?is_prewarmed=true)
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

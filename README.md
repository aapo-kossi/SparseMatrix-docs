# Sparse Matrix Library


This project implements a **sparse matrix library** in C++, designed to handle both **dynamic (uncompressed)** and **compressed** storage formats. It supports matrix-vector multiplication, conversion between storage formats, norm calculations, and reading matrices from [Matrix Market](https://math.nist.gov/MatrixMarket/) files.

This project was developed as part of the Challenge 2 assignment for the 2024–2025 Advanced Programming for Scientific Computing Course at Politecnico di Milano.

---
## Functionality

- **Templated Sparse Matrix Class**:
  `Matrix<T, StorageOrder>` supports both `row-major` and `column-major` layouts. It stores data in either **compressed** or **dynamic (uncompressed)**.

- **Uncompressed (Dynamic) Format**:
  Backed by a `std::map`, this format allows random insertions, deletions, and element modifications.

- **Compressed Format**:
  Uses **CSR (Compressed Sparse Row)** for row-major matrices and **CSC (Compressed Sparse Column)** for column-major ones. This format provides efficient iteration and matrix-vector multiplication.

- **Automatic Format Detection**:
  You can check if a matrix is compressed using `.is_compressed()` and convert formats using `.compress()` or `.uncompress()`.

- **Efficient Matrix-Vector Multiplication**:
  Supports multiplication with both `std::vector<T>` and `Matrix<T, StorageOrder>` objects interpreted as column vectors. Optimized paths for both compressed and uncompressed formats.

- **Matrix Norms**:
  Implements `L1`, `L∞`, and Frobenius norms via `norm<N>()`, with optional parallelism. Norms are computed differently depending on compression format for best performance.

- **Support for Scalar and Complex Types**:
  Template-based design allows storage of real, complex, and integer values.

- **MatrixMarket Reader**:
  Load `.mtx` files using `matrix_market_read(...)` — supports general real and complex matrices.

- **Architecture-Specific Optimization**:
  If AVX512 compatibility is detected on the build architecture, custom SIMD kernels are used to speed up norm computation in specific cases where automatic vectorisation is difficult.


---

## Build Instructions

1. Clone the repository:
   ```bash
   git clone git@github.com:PACS-24-25/challenge2-barabadabastu.git
   cd challenge2-barabadabastu
   ```

2. Build the project using `make`:

   ```bash
   make
   ```

   This will compile the source files and generate the executable `bin/main` using the **release** configuration.

---

### Compilation

This project uses a **Makefile** to simplify compilation and support different build modes.

The following targets are defined by the Makefile:

| Mode          | Command                  | Description                                                                 |
|---------------|--------------------------|-----------------------------------------------------------------------------|
| **release**   | `make` or `make release` | Builds optimized code using `-Ofast`, **without warnings**. Use this for running benchmarks or production. |
| **debug**     | `make debug`             | Builds with **no optimization**, full warnings, and debug symbols. Use this to debug code. |
| **profile**   | `make profile`           | Builds with **optimization and debug symbols**. Use this to analyze performance (e.g. with `gprof`, `perf`, or `valgrind`). |
| **docs**      | `make docs`              | Builds the project documentation using [Doxygen](https://www.doxygen.nl/). |
| **clean**     | `make clean`             | Removes the existing compiled objects and generated dependency files |
| **distclean** | `make distclean`         | Similar to `clean`, but also removes the main executable, backup files and temporary files |

The build modes for compiling the executable **do not automatically clean** previously compiled files.
Be sure to run `make clean` or `make disctlean` before changing build configuration between `release`, `debug` and `profile`.

---

### Running the Program

After compilation, you can run the test program using:

```bash
./bin/main --dtype=double --test-matrix=path/to/matrix.mtx
```

For more on how to use and run the program, see the [Example Usage](#example-usage) section below.

---

### Requirements

- A C++20-compliant compiler (e.g. `g++ 10` or later, `clang++ 12` or later)
- `make`
- OpenMP support for multithreading
- [GetPot](https://getpot.sourceforge.net) (automatically included via `-I` if you set `PACS_ROOT`)
- Linux or Unix-like environment (WSL works on Windows)
- [Intel Threading Building Blocks](https://www.intel.com/content/www/us/en/developer/tools/oneapi/onetbb.html)
- Optional:
  - Doxygen for building the documentation
  - `curl` and `gzip` for automatically downloading a set of sample matrices

If you are working in the PACS course environment, the `PACS_ROOT` variable is automatically set. If not, you can set it manually before building:

```bash
export PACS_ROOT=/path/to/pacs-resources
make
```

---

## Obtaining MatrixMarket files

The project includes a shell script helper `download_test_matrices.sh` fow downloading Matrix Market files.
The downloaded matrices will be placed in a `$PWD/data` directory as uncompressed .mtx files.
Below commands show an example usage of the script:

```console
akossi@IdeaPad ~/p/c/p/challenge2-barabadabastu (main)> ./download_test_matrices.sh
https://math.nist.gov/pub/MatrixMarket2/Harwell-Boeing/lns/lnsp_131.mtx.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3322  100  3322    0     0   1738      0  0:00:01  0:00:01 --:--:--  1738
https://math.nist.gov/pub/MatrixMarket2/misc/qcd/conf6.0-00l8x8-8000.mtx.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 14.8M  100 14.8M    0     0  1848k      0  0:00:08  0:00:08 --:--:-- 2972k
https://math.nist.gov/pub/MatrixMarket2/SPARSKIT/fidap/fidap011.mtx.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 8396k  100 8396k    0     0  4248k      0  0:00:01  0:00:01 --:--:-- 4247k
akossi@IdeaPad ~/p/c/p/challenge2-barabadabastu (main)> tree data
data
├── Harwell-Boeing_lns_lnsp_131.mtx
├── misc_qcd_conf6.0-00l8x8-8000.mtx
└── SPARSKIT_fidap_fidap011.mtx

1 directory, 3 files

```
To download different matrices, you need to add or replace the entries in the `matrix_names` variable in the the script.

---

## Running the Test Suite

To run the test program, you should provide **two required parameters**:

1. `--test-matrix=<path>`
   Path to a `.mtx` file in [MatrixMarket](https://math.nist.gov/MatrixMarket/) format.
   If this parameter is not specified, the test program tries to read a matrix stored in `data/lnsp_131.mtx`.

2. `--dtype=<type>`
   Data type of the matrix elements. Supported types are:
   `double`, `float`, `complex-double`, `complex-float`, `int32`, `int64`.
   By default, the matrix is created with `double` elements. The string `complex` can be used as a shorthand for `complex-double`.

⚠️ It is the user's responsibility to supply the test matrix path and datatype correctly when launching the program. The data-type needs to be compatible with the data-type of the provided matrix.

---

### Example Usage

```bash
./main --test-matrix=data/lnsp_131.mtx --dtype=complex
```

The test routine will:
- Load the matrix into both row-major and column-major representations
- Apply matrix-vector multiplication in both compressed and uncompressed formats
- Measure and compare matrix norms using both sequential and parallel execution
- Test insertions and dynamic resizing capabilities in uncompressed mode
- Evaluate the performance of compression and decompression
- Time each operation
- Print results

---

## Project Structure

```
.
├── include/                      # Header files
│   ├── CanonicalTypes.hpp
│   ├── Matrix.hpp
│   ├── MatrixIntrinsics.hpp
│   ├── MatrixTraits.hpp
│   ├── matrix_reader.hpp
│   ├── tests.hpp
│   └── ThreadedAccumulator.hpp
├── src/                          # Source files
│   ├── main.cpp
│   └── ThreadedAccumulator.cpp
├── .github/, .vscode/            # GitHub and VS Code config directories
├── Challenge24-25-2.pdf          # Assignment description
├── download_test_matrices.sh     # helper script to download example matrices
├── Doxyfile                      # Doxygen configuration
├── LICENSE                       # Project license
├── Makefile                      # Build system
└── README.md                     # Project documentation
```


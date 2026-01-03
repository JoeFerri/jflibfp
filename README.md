[![License: AGPL v3](https://img.shields.io/badge/license-AGPL_v3-blue?style=flat-square&logo=gnu)](https://www.gnu.org/licenses/agpl-3.0)
[![GitHub issues](https://img.shields.io/github/issues/JoeFerri/jflibfp)](https://github.com/JoeFerri/jflibfp/issues)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](code_of_conduct-eng.md)

# jflibfp

**jflibfp** is a header-only / source-only utility library for **Free Pascal**. 

Unlike standard libraries, it is not designed to be compiled as a standalone binary (like a .dll or .so). Instead, it provides a collection of reusable units, algorithms, and data types that can be directly integrated into any Free Pascal or Lazarus project.

## Project Philosophy

This library serves as a central repository for generalized code developed during my software projects (such as [**StarTools**](https://github.com/JoeFerri/StarTools)). Whenever I implement a feature, algorithm, or shell management routine that is useful across multiple applications, I refactor and move it here.

## Key Features

* **Source-only:** Easy to integrate, no complex linking required.
* **Utility Units:** General-purpose helpers for common tasks (e.g., Shell integration, string manipulation, system utilities).
* **Lightweight:** Includes only what you need by adding the units to your project's search path.
* **Developed for StarTools:** Battle-tested in real-world applications.

## How to Use

To use **jflibfp** in your project:

1.  Clone or download this repository.
2.  Copy the source files into your project's library folder (e.g., `libs/jflibfp/`).
3.  In **Lazarus**, go to `Project Options > Compiler Options > Paths` and add the jflibfp folder to the **Other unit files** search path.
4.  Add the desired units to your `uses` clause.

---

## Documentation

### Technical Documentation

For the documentation see the notes inside the source code or [docs page](https://joeferri.github.io/jflibfp/)

---

## Prerequisites

To compile jflibfp, you need to have the following tools installed on your system:

* **IDE:** [Lazarus 4.4](https://www.lazarus-ide.org/)
* **Compiler:** [Free Pascal 3.2.2](https://www.freepascal.org/)
* **Documentation Tools:** [PasDoc](https://pasdoc.github.io/) and [Graphviz](https://graphviz.org/) (required only if you want to generate the documentation via Makefile).
* **Environment:** [WSL2 (Ubuntu)](https://learn.microsoft.com/en-us/windows/wsl/install) is required to run the provided `Makefile` on Windows 11.

## Step-by-Step Instructions

### 1. Clone the Repository
Start by cloning this repository to your local machine:
```bash
git clone https://github.com/JoeFerri/jflibfp.git
```
cd jflibfp

### 2. Install External Dependencies
-

### 3. Build with Lazarus
Open Lazarus IDE.

Press `F9` (or `Run -> Build`) to compile the executable.

### 4. Generate Documentation
If you are using **WSL2** and have **PasDoc**/**Graphviz** installed, you can regenerate the technical documentation:

Open your **WSL2** terminal.

Navigate to the root folder of the project.

Run the following command:

```bash
make full-doc
```

This will generate the HTML documentation and the Graphviz class/use diagrams inside the `docs/` folder.

---

### Code of conduct

[ENG](code_of_conduct-eng.md)

[ITA](code_of_conduct-ita.md)

---

## Contribution Guidelines

[Contribution Guidelines](https://github.com/JoeFerri/jflibfp/CONTRIBUTING.md)

---

# License 

## AGPL-3.0 license 

Copyright (c) 2025 Giuseppe Ferri

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

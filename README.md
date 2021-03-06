

pwsh-tool-belt
=====
A ~~small~~ _nano_ framework for organizing miscellaneous PowerShell functions/scripts in your repertoire for every-day slingin'.

## Description
The tool belt consists of two main objects:
* **Tool Category** - PowerShell module packaged with **pwsh-tool-belt**, named _pwsh-tool-belt/tool\_category_
* **Tool** - PowerShell script and its dependencies stored in a tool category

The framework is meant to store diverse tools for various categories (e.g. security, networking, console fun) and should not have any constraints other than the following:
1. Keep the tools simple
2. Strive for modularity
3. Use approved verbs and descriptive nouns in your tools

The tools included in the framework should be sufficiently small such that they do not deserve their own modules. If you find that the tool that you are adding is becoming complex, just create a standalone module for it.

Additionally, each tool should be sufficiently isolated such that it has minimal external dependencies. If a tool does require dependencies, the dependencies should be placed in the _public_ or _private_ directory in the same tool category as the tool, even if they do not necessarily match that category. Again, though, just create a standalone module if you require many and/or complex dependencies.

## Usage
### Existing Tool Categories
To use tools that already exist in the tool belt, simply import the tool belt module:
   ```powershell
   Import-Module "pwsh-tool-belt.psm1" -Force
   ```

### Adding New Tool Categories
To create a new tool category in your tool belt:
1. Add the category:
   ```powershell 
   Add-ToolCategory -ToolCategoryName name
   ```
   * This will update the tool belt's manifest with the new tool category module automatically.
2. Add new tools to your category. Put each tool's public function in the category's _public_ directory and its helper functions/internal dependencies in the _private_ directory.
   * If the helper functions/dependencies are tools themselves and should be exported, put them in the _public_ directory as well.
3. Build the category's module file (.psm1).
   * This is at the adder's discretion, but the module file should enforce public/private exporting like _pwsh-tool-belt.psm1_.
4. Build the category's manifest file (.psd1) with:
   ```powershell
   New-ModuleManifest -Path "pwsh-tool-belt/tool_category.psd1" @manifestParameters
   ```
5. (optional) Update the tool belt's manifest with any tools added in Step 3 with:
   ```powershell
   Update-ToolBeltManifest
   ```
   * The tool belt's manifest will be updated with any changes on the next addition/removal of a tool category as well.
6. (optional) Import the category's module with:
   ```powershell
   Import-Module "pwsh-tool-belt/tool_category.psm1" -Force
   ```
     or
   ```powershell
   Import-Module "pwsh-tool-belt.psm1" -Force
   ```
   * The second option will re-import the tool belt itself and _all_ tool categories.
   
### Removing Existing Categories
To remove an existing tool category from your tool belt:
1. Remove the category:
   ```powershell
   Remove-ToolCategory -ToolCategoryName name
   ```
   * This will remove the category and all contained tools from disk and from the tool belt's manifest automatically
2. Remove the category's module from the global scope:
   ```powershell
   Remove-Module name
   ```
   * This step is unnecessary if Step 6 of **Adding New Tool Categories** was not completed _and_ the tool belt has not been re-imported since the category was created.

\*\* The category's tools can also be removed from the global scope without removing the category from your tool belt by skipping Step 1.

## Limitations
* The adder of a tool category must build its module and manifest files from scratch, even though the files exist; these should be templatized.
* Adding/updating a tool category does **not** automatically load the category module to the global scope.
* Removing a tool category does **not** automatically unload the category module from the global scope if it has been loaded to the global scope.
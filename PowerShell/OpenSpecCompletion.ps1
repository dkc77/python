# PowerShell completion script for OpenSpec CLI
# Auto-generated - do not edit manually

# Dynamic completion helpers

function Get-OpenSpecChanges {
    $output = openspec __complete changes 2>$null
    if ($output) {
        $output | ForEach-Object {
            ($_ -split "\t")[0]
        }
    }
}

function Get-OpenSpecSpecs {
    $output = openspec __complete specs 2>$null
    if ($output) {
        $output | ForEach-Object {
            ($_ -split "\t")[0]
        }
    }
}

$openspecCompleter = {
    param($wordToComplete, $commandAst, $cursorPosition)

    $tokens = $commandAst.ToString() -split "\s+"
    $commandCount = ($tokens | Measure-Object).Count

    # Top-level commands
    if ($commandCount -eq 1 -or ($commandCount -eq 2 -and $wordToComplete)) {
        $commands = @(
            @{Name="init"; Description="Initialize OpenSpec in your project"},
            @{Name="update"; Description="Update OpenSpec instruction files"},
            @{Name="list"; Description="List items (changes by default, or specs with --specs)"},
            @{Name="view"; Description="Display an interactive dashboard of specs and changes"},
            @{Name="validate"; Description="Validate changes and specs"},
            @{Name="show"; Description="Show a change or spec"},
            @{Name="archive"; Description="Archive a completed change and update main specs"},
            @{Name="feedback"; Description="Submit feedback about OpenSpec"},
            @{Name="change"; Description="Manage OpenSpec change proposals (deprecated)"},
            @{Name="spec"; Description="Manage OpenSpec specifications"},
            @{Name="completion"; Description="Manage shell completions for OpenSpec CLI"},
            @{Name="config"; Description="View and modify global OpenSpec configuration"},
            @{Name="schema"; Description="Manage workflow schemas"}
        )
        $commands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterValue", $_.Description)
        }
        return
    }

    $command = $tokens[1]

    switch ($command) {
        "init" {
            if ($wordToComplete -like "-*") {
                $flags = @(
                    @{Name="--tools"; Description="Configure AI tools non-interactively (e.g., ""all"", ""none"", or comma-separated tool IDs)"}
                )
                $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                }
                return
            }

        }
        "update" {
        }
        "list" {
            if ($wordToComplete -like "-*") {
                $flags = @(
                    @{Name="--specs"; Description="List specs instead of changes"},
                    @{Name="--changes"; Description="List changes explicitly (default)"}
                )
                $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                }
                return
            }

        }
        "view" {
        }
        "validate" {
            if ($wordToComplete -like "-*") {
                $flags = @(
                    @{Name="--all"; Description="Validate all changes and specs"},
                    @{Name="--changes"; Description="Validate all changes"},
                    @{Name="--specs"; Description="Validate all specs"},
                    @{Name="--type"; Description="Specify item type when ambiguous"},
                    @{Name="--strict"; Description="Enable strict validation mode"},
                    @{Name="--json"; Description="Output validation results as JSON"},
                    @{Name="--concurrency"; Description="Max concurrent validations (defaults to env OPENSPEC_CONCURRENCY or 6)"},
                    @{Name="--no-interactive"; Description="Disable interactive prompts"}
                )
                $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                }
                return
            }

            $items = @(Get-OpenSpecChanges) + @(Get-OpenSpecSpecs)
            $items | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
            }
        }
        "show" {
            if ($wordToComplete -like "-*") {
                $flags = @(
                    @{Name="--json"; Description="Output as JSON"},
                    @{Name="--type"; Description="Specify item type when ambiguous"},
                    @{Name="--no-interactive"; Description="Disable interactive prompts"},
                    @{Name="--deltas-only"; Description="Show only deltas (JSON only, change-specific)"},
                    @{Name="--requirements-only"; Description="Alias for --deltas-only (deprecated, change-specific)"},
                    @{Name="--requirements"; Description="Show only requirements, exclude scenarios (JSON only, spec-specific)"},
                    @{Name="--no-scenarios"; Description="Exclude scenario content (JSON only, spec-specific)"},
                    @{Name="--requirement"; Description="Show specific requirement by ID (JSON only, spec-specific)"},
                    @{Name="-r"; Description="Show specific requirement by ID (JSON only, spec-specific)"}
                )
                $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                }
                return
            }

            $items = @(Get-OpenSpecChanges) + @(Get-OpenSpecSpecs)
            $items | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
            }
        }
        "archive" {
            if ($wordToComplete -like "-*") {
                $flags = @(
                    @{Name="--yes"; Description="Skip confirmation prompts"},
                    @{Name="-y"; Description="Skip confirmation prompts"},
                    @{Name="--skip-specs"; Description="Skip spec update operations"},
                    @{Name="--no-validate"; Description="Skip validation (not recommended)"}
                )
                $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                }
                return
            }

            Get-OpenSpecChanges | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Change: $_")
            }
        }
        "feedback" {
            if ($wordToComplete -like "-*") {
                $flags = @(
                    @{Name="--body"; Description="Detailed description for the feedback"}
                )
                $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                }
                return
            }

        }
        "change" {
            if ($commandCount -eq 2 -or ($commandCount -eq 3 -and $wordToComplete)) {
                $subcommands = @(
                    @{Name="show"; Description="Show a change proposal"},
                    @{Name="list"; Description="List all active changes (deprecated)"},
                    @{Name="validate"; Description="Validate a change proposal"}
                )
                $subcommands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterValue", $_.Description)
                }
                return
            }

            $subcommand = if ($commandCount -gt 2) { $tokens[2] } else { "" }
            switch ($subcommand) {
                "show" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--deltas-only"; Description="Show only deltas (JSON only)"},
                            @{Name="--requirements-only"; Description="Alias for --deltas-only (deprecated)"},
                            @{Name="--no-interactive"; Description="Disable interactive prompts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                    Get-OpenSpecChanges | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Change: $_")
                    }
                }
                "list" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--long"; Description="Show id and title with counts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "validate" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--strict"; Description="Enable strict validation mode"},
                            @{Name="--json"; Description="Output validation results as JSON"},
                            @{Name="--no-interactive"; Description="Disable interactive prompts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                    Get-OpenSpecChanges | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Change: $_")
                    }
                }
            }
        }
        "spec" {
            if ($commandCount -eq 2 -or ($commandCount -eq 3 -and $wordToComplete)) {
                $subcommands = @(
                    @{Name="show"; Description="Show a specification"},
                    @{Name="list"; Description="List all specifications"},
                    @{Name="validate"; Description="Validate a specification"}
                )
                $subcommands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterValue", $_.Description)
                }
                return
            }

            $subcommand = if ($commandCount -gt 2) { $tokens[2] } else { "" }
            switch ($subcommand) {
                "show" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--requirements"; Description="Show only requirements, exclude scenarios (JSON only)"},
                            @{Name="--no-scenarios"; Description="Exclude scenario content (JSON only)"},
                            @{Name="--requirement"; Description="Show specific requirement by ID (JSON only)"},
                            @{Name="-r"; Description="Show specific requirement by ID (JSON only)"},
                            @{Name="--no-interactive"; Description="Disable interactive prompts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                    Get-OpenSpecSpecs | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Spec: $_")
                    }
                }
                "list" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--long"; Description="Show id and title with counts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "validate" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--strict"; Description="Enable strict validation mode"},
                            @{Name="--json"; Description="Output validation results as JSON"},
                            @{Name="--no-interactive"; Description="Disable interactive prompts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                    Get-OpenSpecSpecs | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Spec: $_")
                    }
                }
            }
        }
        "completion" {
            if ($commandCount -eq 2 -or ($commandCount -eq 3 -and $wordToComplete)) {
                $subcommands = @(
                    @{Name="generate"; Description="Generate completion script for a shell (outputs to stdout)"},
                    @{Name="install"; Description="Install completion script for a shell"},
                    @{Name="uninstall"; Description="Uninstall completion script for a shell"}
                )
                $subcommands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterValue", $_.Description)
                }
                return
            }

            $subcommand = if ($commandCount -gt 2) { $tokens[2] } else { "" }
            switch ($subcommand) {
                "generate" {
                    $shells = @("zsh", "bash", "fish", "powershell")
                    $shells | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Shell: $_")
                    }
                }
                "install" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--verbose"; Description="Show detailed installation output"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                    $shells = @("zsh", "bash", "fish", "powershell")
                    $shells | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Shell: $_")
                    }
                }
                "uninstall" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--yes"; Description="Skip confirmation prompts"},
                            @{Name="-y"; Description="Skip confirmation prompts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                    $shells = @("zsh", "bash", "fish", "powershell")
                    $shells | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
                        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", "Shell: $_")
                    }
                }
            }
        }
        "config" {
            if ($wordToComplete -like "-*") {
                $flags = @(
                    @{Name="--scope"; Description="Config scope (only ""global"" supported currently)"}
                )
                $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                }
                return
            }

            if ($commandCount -eq 2 -or ($commandCount -eq 3 -and $wordToComplete)) {
                $subcommands = @(
                    @{Name="path"; Description="Show config file location"},
                    @{Name="list"; Description="Show all current settings"},
                    @{Name="get"; Description="Get a specific value (raw, scriptable)"},
                    @{Name="set"; Description="Set a value (auto-coerce types)"},
                    @{Name="unset"; Description="Remove a key (revert to default)"},
                    @{Name="reset"; Description="Reset configuration to defaults"},
                    @{Name="edit"; Description="Open config in `$EDITOR"},
                    @{Name="profile"; Description="Configure workflow profile (interactive picker or preset shortcut)"}
                )
                $subcommands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterValue", $_.Description)
                }
                return
            }

            $subcommand = if ($commandCount -gt 2) { $tokens[2] } else { "" }
            switch ($subcommand) {
                "path" {
                }
                "list" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "get" {
                }
                "set" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--string"; Description="Force value to be stored as string"},
                            @{Name="--allow-unknown"; Description="Allow setting unknown keys"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "unset" {
                }
                "reset" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--all"; Description="Reset all configuration (required)"},
                            @{Name="--yes"; Description="Skip confirmation prompts"},
                            @{Name="-y"; Description="Skip confirmation prompts"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "edit" {
                }
                "profile" {
                }
            }
        }
        "schema" {
            if ($commandCount -eq 2 -or ($commandCount -eq 3 -and $wordToComplete)) {
                $subcommands = @(
                    @{Name="which"; Description="Show where a schema resolves from"},
                    @{Name="validate"; Description="Validate a schema structure and templates"},
                    @{Name="fork"; Description="Copy an existing schema to project for customization"},
                    @{Name="init"; Description="Create a new project-local schema"}
                )
                $subcommands | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterValue", $_.Description)
                }
                return
            }

            $subcommand = if ($commandCount -gt 2) { $tokens[2] } else { "" }
            switch ($subcommand) {
                "which" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--all"; Description="List all schemas with their resolution sources"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "validate" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--verbose"; Description="Show detailed validation steps"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "fork" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--force"; Description="Overwrite existing destination"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
                "init" {
                    if ($wordToComplete -like "-*") {
                        $flags = @(
                            @{Name="--json"; Description="Output as JSON"},
                            @{Name="--description"; Description="Schema description"},
                            @{Name="--artifacts"; Description="Comma-separated artifact IDs"},
                            @{Name="--default"; Description="Set as project default schema"},
                            @{Name="--no-default"; Description="Do not prompt to set as default"},
                            @{Name="--force"; Description="Overwrite existing schema"}
                        )
                        $flags | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
                            [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, "ParameterName", $_.Description)
                        }
                        return
                    }

                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName openspec -ScriptBlock $openspecCompleter

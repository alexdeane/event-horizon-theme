# Directory to save the generated theme files to
$outputDirectory = '..\src\main\resources\META-INF\'

# Load the various config files
$configs = Get-ChildItem -Path '.\configurations' -Filter '*.json'

# Load the two template files
$schemeTemplateContent = Get-Content '.\templates\scheme.template.xml'
$themeTemplateContent = Get-Content '.\templates\theme.template.json'

# Generate the plugin.xml file from the template
[xml]$pluginXmlContent = Get-Content '.\templates\plugin.template.xml';
$extensionsNode = $pluginXmlContent.SelectSingleNode('//extensions');

# For each configuration file, generate the theme files
foreach($config in $configs) {
    echo "Generating theme from configuration: $($config.Name)"

    # Load and parse the configuration file
    $content = Get-Content -Path $config.FullName -Raw | ConvertFrom-Json

    # Initialize the content and replace the fileName token
    $schemeFileContent = $schemeTemplateContent.Replace('%%fileName%%', $config.BaseName)
    $themeFileContent = $themeTemplateContent.Replace('%%fileName%%', $config.BaseName)

    # Token replace the contents of the template file
    foreach ($token in $content.PSObject.Properties)
    {
        $tokenName = "%$( $token.Name )%";
        echo "Replacing token: $tokenName with '$($token.Value)'";

        $schemeFileContent = $schemeFileContent.Replace($tokenName, $token.Value)
        $themeFileContent = $themeFileContent.Replace($tokenName, $token.Value)
    }

    # Save the files to the output directory
    echo "Saving scheme file $($config.BaseName).xml...";
    Set-Content -Path "$outputDirectory/$($config.BaseName).xml" -Value $schemeFileContent

    echo "Saving theme file $($config.BaseName).theme.json...";
    Set-Content -Path "$outputDirectory/$($config.BaseName).theme.json" -Value $themeFileContent

    # Add the theme to the plugin.xml file
    $extensionNode = $pluginXmlContent.CreateElement('themeProvider')
    $extensionNode.SetAttribute('id', [Guid]::NewGuid().ToString())
    $extensionNode.SetAttribute('path', "/META-INF/$($config.BaseName).theme.json")

    $foo = $extensionsNode.AppendChild($extensionNode)
}

# Save the plugin.xml file to the output directory
echo "Saving plugin.xml file...";
Set-Content -Path "$outputDirectory/plugin.xml" -Value $pluginXmlContent.OuterXml

echo "Theme generation completed successfully"
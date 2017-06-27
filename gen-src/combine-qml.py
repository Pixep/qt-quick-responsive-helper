import re
import os
from shutil import copyfile

def trimComponent(componentLines):
    linesToDelete = []
    for i in range(len(componentLines)):
        if componentLines[i].startswith('import') or componentLines[i] == '\n':
            linesToDelete.append(i)

    for lineIndex in reversed(linesToDelete):
        del componentLines[lineIndex]

# Removes components original properties when redefined in final file
def filterRedefinedProperties(componentLines, contentLines):
    linesToAdd = componentLines[:]
    propertyRegexp = re.compile(r'^(\s*)(property\s+\w+\s+)?(\w+)\s*:(.*$)')

    for contentIndex, contentLine in enumerate(contentLines):
        matchInRedefinition = propertyRegexp.search(contentLine)

        if matchInRedefinition:
            deleteLineIndex = -1
            propertyIndentation = matchInRedefinition.group(1)
            propertyName = matchInRedefinition.group(3)
            propertyValue = matchInRedefinition.group(4)
            openedBraces = 0
            for lineIndex in range(len(linesToAdd)):

                if linesToAdd[lineIndex].find('{') >= 0:
                    openedBraces += 1
                if linesToAdd[lineIndex].find('}') >= 0:
                    openedBraces -= 1

                if openedBraces == 1:
                    matchInOriginal = re.match(r'^\s+((property\s+\w+\s+)?' + propertyName + '\s*:)', linesToAdd[lineIndex])
                    if matchInOriginal:
                        propertyDeclaration = matchInOriginal.group(1)

                        # Combine original declaration, and value redefinition
                        newLine = propertyDeclaration + propertyValue + '\n'
                        newLine = propertyIndentation + newLine

                        contentLines[contentIndex] = newLine
                        deleteLineIndex = lineIndex
                        print 'merging line ' + linesToAdd[lineIndex]
                        break

            if deleteLineIndex >= 0:
                del linesToAdd[deleteLineIndex]

    return linesToAdd

# Returns the component merged with its local content
def mergedComponent(componentLines, contentLines, indentation):
    comp = ''
    filteredComponentLines = filterRedefinedProperties(componentLines=componentLines, contentLines=contentLines)

    # Insert component code
    for line in filteredComponentLines:
        if line.find('}') == 0:
            break
        else:
            comp += indentation + line

    if len(contentLines) > 0:
        comp += indentation + '    //---- Redefinitions ----\n'

    # Insert code form its content
    for contentLine in contentLines:
        comp += contentLine

    return comp

# Replaces component tokens by content of a file
def mergeComponentInDocument(originalFilePath, componentFilePath, componentName):
    print 'Merging @' + componentName + ' (' + componentFilePath + ') into ' + originalFilePath

    # Read component
    try:
        componentFile = open(componentFilePath)
        componentLines = componentFile.readlines()
    except:
        print 'Failed to open file ' + componentFilePath
        return

    trimComponent(componentLines)

    # Open destination file
    try:
        originalFile = open(originalFilePath, 'r+')
    except:
        print 'Failed to open file ' + originalFilePath
        return

    # Insert component in file
    finalFileContent = ''
    componentRegexp = re.compile(r'^(\s*)@'+componentName+' ?{')
    insertingComponent = False
    indentation = ''

    for line in originalFile:
        if insertingComponent == False:
            res = componentRegexp.search(line)
            if res:
                indentation = res.group(1)
                contentLines = []
                insertingComponent = True
                openedBraces = 1
            else:
                finalFileContent += line
        else:
            if line.find('{') >= 0:
                openedBraces += 1
            if line.find('}') >= 0:
                openedBraces -= 1

            if openedBraces > 0:
                contentLines.append(line)
            else:
                insertingComponent = False
                comp = mergedComponent(componentLines=componentLines, contentLines=contentLines, indentation=indentation)
                finalFileContent += indentation + '//---------------\n'
                finalFileContent += indentation + '// @' + componentName + '\n'
                finalFileContent += comp
                finalFileContent += line

    originalFile.seek(0)
    originalFile.write(finalFileContent)
    originalFile.truncate()

copyfile('main.original.qml', 'main.temp.qml')
mergeComponentInDocument('main.temp.qml', 'Button.qml', 'Button')

print open('main.temp.qml').read()
os.remove('main.temp.qml')

copyfile('ResponsiveHelper.original.qml', 'ResponsiveHelper.temp.qml')
mergeComponentInDocument('ResponsiveHelper.temp.qml', 'Button.qml', 'Button')
copyfile('ResponsiveHelper.temp.qml', '../ResponsiveHelper.qml')
os.remove('ResponsiveHelper.temp.qml')

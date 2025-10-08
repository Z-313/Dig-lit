#!/bin/bash
# Quick project structure visualizer

cd /workspaces/Dig-lit

echo "🌳 Current Project Structure:"
echo ""

# Show main structure
tree -L 3 -I 'node_modules|__pycache__|.git|dist|build|.next|.turbo' modules/

echo ""
echo "📊 Module Statistics:"
echo ""

for module in modules/*; do
    if [ -d "$module" ]; then
        module_name=$(basename "$module")
        files=$(find "$module" -type f -not -path "*/node_modules/*" -not -path "*/__pycache__/*" | wc -l)
        dirs=$(find "$module" -type d -not -path "*/node_modules/*" -not -path "*/__pycache__/*" | wc -l)
        
        if [ "$files" -eq 0 ]; then
            echo "  📁 $module_name: ❌ EMPTY ($dirs dirs, 0 files)"
        else
            echo "  📁 $module_name: ✅ ACTIVE ($dirs dirs, $files files)"
        fi
    fi
done

echo ""
echo "💡 Run 'npm run structure:cleanup' to optimize structure"

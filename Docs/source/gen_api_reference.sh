appledoc -p "MetaWear iOS/macOS/tvOS API 2.8.4" --project-version "2.8.4" -c "MBIENTLAB INC" --company-id com.mbientlab --no-create-docset --no-repeat-first-par --ignore .m -o . ../MetaWear/Classes
open html/index.html

make html
open build/html/index.html

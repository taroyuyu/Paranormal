import Cocoa
import Quick
import Nimble
import Paranormal
import CoreGraphics

class DocumentTests: QuickSpec {
    override func spec() {
        describe("Document") {
            describe("initialization") {
                var document : Document!

                beforeEach {
                    document = DocumentController()
                        .makeUntitledDocumentOfType("Paranormal", error: nil) as Document
                }

                it("does not leave anything in the undo stack") {
                    document.windowControllerDidLoadNib(NSWindowController())
                    expect(document.undoManager?.canUndo).to(beFalsy())
                }

                it("creates 1 Refraction entity") {
                    let refractionFetch = NSFetchRequest(entityName: "Refraction")
                    let refractionResult : NSArray? =
                        document.managedObjectContext
                            .executeFetchRequest(refractionFetch, error: nil)
                    expect(refractionResult?.count).to(equal(1))
                }

                it("creates 1 DocumentSettings entity") {
                    let documentFetch = NSFetchRequest(entityName: "DocumentSettings")
                    let documentResult : NSArray? =
                    document.managedObjectContext.executeFetchRequest(documentFetch, error: nil)
                    expect(documentResult?.count).to(equal(1))
                }

                it("creates 1 default layer entity") {
                    let layerFetch = NSFetchRequest(entityName: "Layer")
                    let layerResult : NSArray? =
                    document.managedObjectContext.executeFetchRequest(layerFetch, error: nil)
                    // One layer for container / root. One to draw on.
                    expect(layerResult?.count).to(equal(2))
                }

                it("Check number of sublayers") {
                    let documentFetch = NSFetchRequest(entityName: "DocumentSettings")
                    let documentResult : NSArray? =
                        document.managedObjectContext.executeFetchRequest(documentFetch, error: nil)
                    let documentSettings = documentResult?[0] as DocumentSettings
                    let layers = documentSettings.rootLayer?.layers

                    expect(layers?.count).to(equal(1))
                }

                it("Root layer should have imageData") {
                    let documentFetch = NSFetchRequest(entityName: "DocumentSettings")
                    let documentResult : NSArray? =
                    document.managedObjectContext.executeFetchRequest(documentFetch, error: nil)
                    let documentSettings = documentResult?[0] as DocumentSettings
                    let root = documentSettings.rootLayer!
                    expect(root.imageData).toNot(beNil())
                }

                it("sets brush color to ZUP"){
                    expect(document.toolSettings.colorAsNSColor.redComponent).to(equal(0.5))
                    expect(document.toolSettings.colorAsNSColor.greenComponent).to(equal(0.5))
                    expect(document.toolSettings.colorAsNSColor.blueComponent).to(equal(1.0))
                }
            }

            describe ("Initialization on Import") {
                var documentController : DocumentController!

                beforeEach {
                    documentController = DocumentController()
                    let url = NSBundle(forClass: DocumentTests.self)
                        .URLForResource("bear", withExtension: "png")

                    for doc in documentController.documents {
                        documentController.removeDocument(doc as NSDocument)
                    }

                    documentController.createDocumentFromUrl(url!)
                }

                it ("Imports a bear image") {
                    expect(documentController.documents.count).to(equal(1))
                    //import creates a second document
                    let newDocument = documentController.documents[0] as? Document
                    expect(newDocument?.documentSettings?.width).to(equal(161))
                }

                it ("Initializes editor with ZUP in shape of bear") {
                    let newDocument = documentController.documents[0] as? Document
                    PNEditorHelper.waitForEditorImageInDocument(newDocument!)
                    let editorController = newDocument?.singleWindowController?.editorViewController
                        as EditorViewController?

                    //w=161, h=156
                    //check that corners are transparent
                    let editorImage = editorController?.editor.image

                    var color = NSImageHelper.getPixelColor(editorImage!,
                        pos: NSPoint(x: 0.0, y: 0.0)) //lower left
                    expect(color.alphaComponent).to(equal(0))

                    color = NSImageHelper.getPixelColor(editorImage!,
                        pos: NSPoint(x: 0.0, y: 155.0)) //upper left
                    expect(color.alphaComponent).to(equal(0))

                    color = NSImageHelper.getPixelColor(editorImage!,
                        pos: NSPoint(x: 160.0, y: 155.0)) //upper right
                    expect(color.alphaComponent).to(equal(0))

                    color = NSImageHelper.getPixelColor(editorImage!,
                        pos: NSPoint(x: 105.0, y: 8.0))
                    expect(color).to(beColor(127, 127, 255, 255))
                }
            }
        }
    }
}

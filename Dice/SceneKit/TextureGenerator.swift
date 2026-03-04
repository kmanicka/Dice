//
//  TextureGenerator.swift
//  Dice
//
//  Created by Claude Code
//

import UIKit
import SceneKit

class TextureGenerator {

    // Generate individual face texture for each dice face
    static func generateFaceTexture(faceNumber: Int, size: CGSize = CGSize(width: 512, height: 512)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let ctx = context.cgContext

            // Base color - ivory/bone white
            UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            // Draw pips
            UIColor.black.setFill()
            let pipRadius = size.width / 12
            let margin = size.width * 0.25
            let center = size.width * 0.5

            // Helper to draw a pip
            func drawPip(at x: CGFloat, y: CGFloat) {
                let rect = CGRect(x: x - pipRadius, y: y - pipRadius, width: pipRadius * 2, height: pipRadius * 2)
                ctx.fillEllipse(in: rect)
            }

            switch faceNumber {
            case 1:
                // One pip - center
                drawPip(at: center, y: center)

            case 2:
                // Two pips - diagonal
                drawPip(at: margin, y: margin)
                drawPip(at: size.width - margin, y: size.width - margin)

            case 3:
                // Three pips - diagonal
                drawPip(at: margin, y: margin)
                drawPip(at: center, y: center)
                drawPip(at: size.width - margin, y: size.width - margin)

            case 4:
                // Four pips - corners
                drawPip(at: margin, y: margin)
                drawPip(at: size.width - margin, y: margin)
                drawPip(at: margin, y: size.width - margin)
                drawPip(at: size.width - margin, y: size.width - margin)

            case 5:
                // Five pips - corners + center
                drawPip(at: margin, y: margin)
                drawPip(at: size.width - margin, y: margin)
                drawPip(at: center, y: center)
                drawPip(at: margin, y: size.width - margin)
                drawPip(at: size.width - margin, y: size.width - margin)

            case 6:
                // Six pips - two columns
                drawPip(at: margin, y: margin)
                drawPip(at: margin, y: center)
                drawPip(at: margin, y: size.width - margin)
                drawPip(at: size.width - margin, y: margin)
                drawPip(at: size.width - margin, y: center)
                drawPip(at: size.width - margin, y: size.width - margin)

            default:
                break
            }
        }

        return image
    }

    static func generateNormalMap(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // Normal map - neutral blue (pointing straight out)
            UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        return image
    }

    static func generateRoughnessMap(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // Matte surface (high roughness = light gray) - prevents shininess
            UIColor(white: 0.75, alpha: 1.0).setFill()  // Increased from 0.3 to 0.75
            context.fill(CGRect(origin: .zero, size: size))
        }

        return image
    }

    static func generateMetallicMap(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // Non-metallic (black)
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        return image
    }

    static func generateAOMap(size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // No ambient occlusion (white)
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        return image
    }
}

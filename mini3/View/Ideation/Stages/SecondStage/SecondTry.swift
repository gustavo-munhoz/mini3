//
//  SecondTry.swift
//  mini3
//
//  Created by Gustavo Munhoz Correa on 18/11/23.
//

import SwiftUI

struct SecondTry: View {
    @EnvironmentObject var store: AppStore
    @State private var conceptViewSizes: [UUID: CGSize] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(store.state.currentProject?.appearingConcepts ?? []) { conceptPosition in
                ConceptView(model: conceptPosition, isSelected: false, fontSize: calculateFontSize(screenSize: geometry.size)) {
                    // Implemente a ação de seleção aqui
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                let size = geo.size
                                conceptViewSizes[conceptPosition.id] = size
                                positionConceptView(conceptPosition, screenSize: geometry.size, conceptViews: store.state.currentProject?.appearingConcepts ?? [], size: size)
                            }
                    }
                )
                .position(x: conceptPosition.relativeX * geometry.size.width,
                          y: conceptPosition.relativeY * geometry.size.height)
                .opacity(conceptPosition.isVisible ? 1 : 0)
            }
        }
    }
    
    func positionConceptView(_ conceptPosition: ConceptPosition, screenSize: CGSize, conceptViews: [ConceptPosition], size: CGSize) {
        while true {
            // Gerar posição aleatória
            let randomPoint = randomPointInCircle(center: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2), radius: screenSize.width / 2)
            let conceptRect = CGRect(x: randomPoint.x, y: randomPoint.y, width: size.width, height: size.height)
            
            // Verificar se há sobreposição
            var hasOverlap = false
            for otherConcept in conceptViews where otherConcept !== conceptPosition {
                if let otherSize = conceptViewSizes[otherConcept.id] {
                    let otherRect = CGRect(x: otherConcept.relativeX * screenSize.width, y: otherConcept.relativeY * screenSize.height, width: otherSize.width, height: otherSize.height)
                    if conceptRect.intersects(otherRect) {
                        hasOverlap = true
                        break
                    }
                }
            }
            
            if !hasOverlap {
                // Atualizar posição se não houver sobreposição
                conceptPosition.setPosition(relativeX: randomPoint.x / screenSize.width, relativeY: randomPoint.y / screenSize.height)
                conceptPosition.isVisible = true
                break
            }
        }
    }
    
    func randomPointInCircle(center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = CGFloat.random(in: 0..<2 * .pi)
        let randomRadius = CGFloat.random(in: 0..<radius)
        return CGPoint(
            x: center.x + randomRadius * cos(angle),
            y: center.y + randomRadius * sin(angle)
        )
    }
    
    func calculateFontSize(screenSize: CGSize) -> CGFloat {
        let baseFontSize: CGFloat = 8 // Tamanho base para a fonte
        let scaleFactor: CGFloat = 0.02 // Fator de escalonamento para ajustar o tamanho da fonte com base na tela
        
        // Use o menor entre a largura e a altura para o escalonamento para garantir que a fonte se ajuste bem em ambas as dimensões
        let scalingDimension = min(screenSize.width, screenSize.height)
        
        // Calcule o tamanho da fonte ajustado
        let adjustedFontSize = baseFontSize + (scalingDimension * scaleFactor)
        
        return adjustedFontSize
    }
    
}

//
//  SlideView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//

import SwiftUI

struct SlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    if slide.title == "Welcome to App" {
                        GeometryReader { geo in
                            let w = geo.size.width
                            let h = geo.size.height
                            let cardW = w * 0.533
                            let cardH = cardW * 1.25
                            let gap: CGFloat = 16
                            let clusterY = h * 0.34

                            // сам кластер колонн
                            let cluster =
                                HStack(spacing: gap) {
                                    VStack(spacing: gap) {
                                        PhotoCard("ob_face_up",     width: cardW, height: cardH)
                                        PhotoCard("ob_face_center", width: cardW, height: cardH)
                                        PhotoCard("ob_face_down",   width: cardW, height: cardH)
                                    }
                                    .opacity(0.3).offset(y: -28).scaleEffect(0.96)

                                    VStack(spacing: gap) {
                                        PhotoCard("ob_face_up",     width: cardW, height: cardH)
                                        PhotoCard("ob_face_center", width: cardW, height: cardH)
                                        PhotoCard("ob_face_down",   width: cardW, height: cardH)
                                    }

                                    VStack(spacing: gap) {
                                        PhotoCard("ob_face_down",     width: cardW, height: cardH)
                                        PhotoCard("ob_face_up",       width: cardW, height: cardH)
                                        PhotoCard("ob_face_center",   width: cardW, height: cardH)
                                    }
                                    .opacity(0.3).offset(y: -28).scaleEffect(0.96)
                                }
                                .frame(width: w, alignment: .center)
                                .position(x: w/2, y: clusterY)
//                                .padding(.top, -60)

                            cluster
                                .mask(
                                    Rectangle()
                                        .padding(.top, -200)
                                )
                                .clipped()
                        }
                    }

                    if slide.title.contains("Transform") {
                        Image("my_star_photo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: min(geo.size.width * 0.7, 320),
                                   height: min(geo.size.width * 0.7, 320))
                            .position(x: geo.size.width / 2,
                                      y: geo.size.height * 0.45)
                    }

                    if slide.title.contains("viral") {
                        Image("ob_trend")
                            .resizable()
                            .scaledToFill()
                            .frame(width: min(geo.size.width * 0.7, 320),
                                   height: min(geo.size.width * 0.7, 320))
                            .position(x: geo.size.width / 2,
                                      y: geo.size.height * 0.45)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

private struct PhotoCard: View {
    let name: String
    let width: CGFloat
    let height: CGFloat

    init(_ name: String, width: CGFloat, height: CGFloat) {
        self.name = name
        self.width = width
        self.height = height
    }

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview("SlideView — Welcome") {
    GeometryReader { geo in
        SlideView(
            slide: OnboardingSlide(
                title: "Welcome to App",
                subtitle: "Generate unique images and videos in seconds using a neural network",
                background: AnyView(OrangeSolidBG())
            )
        )
        .frame(width: geo.size.width, height: geo.size.height)
        .background(Color.orange)
        .ignoresSafeArea()
    }
}

require 'rubygems'
require 'RMagick'

include Magick

module Noise
    class Noise3D
        def initialize
            @G = []
            255.times do 
                @G << nil

                while true
                    xyz = [rand*2 - 1.0, rand*2 - 1.0, rand*2 - 1.0]
                    @G[-1] = normalize(xyz)
                    break if length(@G[-1]) < 1.0
                end
            end

            @P = (1...255).to_a.shuffle
        end


        def length(xyz)
            x, y, z = xyz
            return Math.sqrt(x**2 + y**2 + z**2)
        end

        alias norm length

        def normalize(xyz)
            x, y, z = xyz
            norm = length(xyz)
            
            return [x/norm, y/norm, z/norm]
        end

        def fold(x,y,z)
            n = @P[x % @P.length]
            n = @P[(n + y) % @P.length]
            n = @P[(n + z) % @P.length]
            return n
        end

        def noise(x, y, z)
            cell = [x.floor, y.floor, z.floor]

            sum = 0.0
            [[0,0,0], [0,0,1], [0,1,1], [0,1,0],
             [1,1,0], [1,0,0], [1,0,1], [1,1,1]].each do |corner|
                i, j, k = [cell[0] + corner[0], 
                           cell[1] + corner[1],
                           cell[2] + corner[2]
                          ]
                u, v, w = [x - i, y - j, z - k]

                gradient = @G[fold(i, j, k) % @G.length]  
                sum += omega(u,v,w) * dot(gradient, [u,v,w])
            end
            return [[sum, 1.0].min, -1.0].max
        end

        def dot(vec1, vec2)
            vec1[0]*vec2[0] + vec1[1]*vec2[1] + vec1[2]*vec2[2]
        end

        def omega(u, v, w)
            drop(u) * drop(v) * drop(w)
        end

        def drop(t)
            t = t.abs
            1.0 - t*t*t*(t*(t*6-15)+10)
        end

        def draw(args={})
            size = args[:size] || [256, 256]
            scale = args[:scale] || 32.0
            file_name = args[:file_name] || args[:output_file] || args[:file]
            z = args[:z] || "0.0"

            canvas = Image.new(size[0], size[1])
            gc = Draw.new


            size[0].times{ |x|
                size[1].times{ |y|
                    n = (128*(noise(x/scale, y/scale, z) + 1)).to_i
                    gc.fill("rgb(#{n},#{n},#{n})")
                    gc.point(x,y)
                }
            }
            gc.draw(canvas)

            canvas.write(file_name)
        end
    end

    class Noise2D
        def initialize
            @G = []
            255.times do 
                @G << nil

                while true
                    xy = [rand * 2 - 1.0, rand * 2 - 1.0]
                    @G[-1] = normalize(xy)
                    break if length(@G[-1]) < 1.0
                end
            end

            @P = (1...255).to_a.shuffle
        end


        def length(xy)
            x, y = xy
            return Math.sqrt(x**2 + y**2)
        end

        alias norm length

        def normalize(xy)
            x, y = xy
            norm = length(xy)
            
            return [x/norm, y/norm]
        end

        def fold(x,y)
            n = @P[x % @P.length]
            n = @P[(n + y) % @P.length]
            return n
        end

        def noise(x, y)
            cell = [x.floor, y.floor]

            sum = 0.0
            [[0,0], [0,1], [1,0], [1,1]].each do |corner|
                i, j = [cell[0] + corner[0], cell[1] + corner[1]]
                u, v = [x - i, y - j]

                gradient = @G[fold(i, j) % @G.length]  
                sum += omega(u,v) * dot(gradient, [u,v])
            end
            return [[sum, 1.0].min, -1.0].max
        end

        def dot(vec1, vec2)
            vec1[0]*vec2[0] + vec1[1]*vec2[1]
        end

        def omega(u, v)
            drop(u) * drop(v)
        end

        def drop(t)
            t = t.abs
            1.0 - t*t*t*(t*(t*6-15)+10)
        end

        def draw(args={})
            size = args[:size] || [256, 256]
            scale = args[:scale] || 32.0
            file_name = args[:file_name] || args[:output_file] || args[:file]

            canvas = Image.new(size[0], size[1])
            gc = Draw.new


            size[0].times{ |x|
                size[1].times{ |y|
                    n = 128*(noise(x/scale, y/scale) + 1)

#                     n1 = noise(x/scale, y/scale) * 1
#                     n2 = noise(x/2*scale, y/2*scale) * 0.5
#                     n3 = noise(x/4*scale, y/4*scale) * 0.25
#                     n4 = noise(x/8*scale, y/8*scale) * 0.125

#                     n = 128*(n1 + n2 + n3 + n4 + 1.875)/1.875

                    gc.fill("rgb(#{n},#{n},#{n})")
                    gc.point(x,y)
                }
            }
            gc.draw(canvas)

            canvas.write(file_name)
        end
    end

#     class PerlinNoise2D
#         def initialize(args={})
#             @smooth = []
#             @persistance = 0.5
#             @scale = args[:scale] || 32.0
#             @octave_count = args[:octave_count] || 4
#             @size = args[:size] || [256, 256]
#             @file_name = args[:file_name] || "noise.png"
#             @noise = Noise2D.new
#         end

#         def generate
#             @octave_count.times { |k|
#                 x = []
#                 @size[0].times { |i|
#                     y = []
#                     @size[1].times { |j|
#                         y << @noise.noise(i*@scale*(@persistance**k), j*@scale*(@persistance**k))
#                     }
#                     x << y
#                 }
#                 @smooth << x
#             }

#             @perlin_noise = [[0]*@size[0]]*@size[1]

#             amplitude = 1.0
#             total_amplitude = 0.0

#             @octave_count.times { |k|
#                 amplitude *= @persistance
#                 total_amplitude += amplitude

#                 @size[0].times{ |i|
#                     @size[1].times{ |j|
#                         @perlin_noise[i][j] += @smooth[k][i][j] * amplitude
#                     }
#                 }
#             }

#             @size[0].times{ |i|
#                 @size[1].times{ |j|
#                     @perlin_noise[i][j] /= total_amplitude
#                 }
#             }

#         end

#         def draw
#             canvas = Image.new(@size[0], @size[1])
#             gc = Draw.new

#             @size[0].times{ |x|
#                 @size[1].times{ |y|
#                     n = (@perlin_noise[x][y] + 1)*128
#                     gc.fill("rgb(#{n},#{n},#{n})")
#                     gc.point(x,y)
#                 }
#             }
#             gc.draw(canvas)

#             canvas.write(@file_name)
#         end
#     end
end

# 10.times do |z|
#     n = Noise::Noise3D.new
#     n.draw :file=>"noise#{z}.png", :size=>[128,128], :scale=>16.0, :z=>z
#     puts "finished #{z}...."
# end

# n = Noise::Noise2D.new
# n.draw :file=>"noise.png", :size=>[128,128], :scale=>16.0

# n = Noise::PerlinNoise2D.new :scale=>(1/2.0)
# n.generate
# n.draw

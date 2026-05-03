
def generate_hdmi_ecc_equations(num_data_bits):
    # G(x) = x^8 + x^6 + x^5 + x + 1
    # Polynomial: 1 0 1 1 0 0 0 1 1 (0x163)
    poly = 0x63

    # Each state bit is a set of indices of the input data bits it depends on
    state = [set() for _ in range(8)]

    for i in range(num_data_bits):
        # feedback = data_bit ^ state[7]
        # We represent data_bit i as {i}
        feedback = {i} ^ state[7]

        new_state = [set() for _ in range(8)]

        # next_state = (state << 1) ^ (feedback if poly bit is set)
        # poly bits (0..7): 1 1 0 0 0 1 1 0 (from 0x63 = 01100011, wait)
        # 0x63 = 01100011 -> bits 0, 1, 5, 6 are set.

        new_state[0] = feedback
        new_state[1] = state[0] ^ feedback
        new_state[2] = state[1]
        new_state[3] = state[2]
        new_state[4] = state[3]
        new_state[5] = state[4] ^ feedback
        new_state[6] = state[5] ^ feedback
        new_state[7] = state[6]

        state = new_state

    return state

def set_to_xor_string(s, prefix='D'):
    indices = sorted(list(s))
    return ' ^ '.join([f'{prefix}{i}' for i in indices])

if __name__ == "__main__":
    print("HDMI Header ECC (24-bit data):")
    header_state = generate_hdmi_ecc_equations(24)
    for i, s in enumerate(header_state):
        print(f"P{i} = {set_to_xor_string(s)}")

    print("\nHDMI Subpacket ECC (56-bit data):")
    subpacket_state = generate_hdmi_ecc_equations(56)
    for i, s in enumerate(subpacket_state):
        print(f"P{i} = {set_to_xor_string(s)}")

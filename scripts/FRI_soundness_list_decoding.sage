from math import log2


def commit_soundness_error_list(field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, m):
    # Returns the log2 soundness error of the FRI commit phase

    # Parameters:
    #    field_bits: The number of bits of the field we are drawing the challenges from.
    #    lde_domain_bits: The log2 of the low-degree extension domain.
    #    trace_domain_bits: The log2 of the trace domain.
    #    fold_arities: A list of the log2 of the folding factors used in the FRI protocol.
    #    num_polys: The degree of the batching plus 1 e.g. for linear batching it is equal to 2.
    #    m: The proximity paramater to the Johnson bound.

    if m < 3:
        print("Proximity parameter m cannot be less than 3")
        return

    trace_len = 2**trace_domain_bits
    domain = 2**lde_domain_bits
    rho = trace_len / domain

    return log2(((num_polys - 0.5) * (domain**2) * (m + 0.5)**7 * rho**(-3/2) / 3) + (2*m + 1) * (domain + 1) * rho**(-1/2) * sum([2**a for a in fold_arities])) - field_bits


def min_achievable_soundness_error(field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys):
    # Returns the minimal achievable log2 soundness error of the FRI commit phase

    # Parameters:
    #    field_bits: The number of bits of the field we are drawing the challenges from.
    #    lde_domain_bits: The log2 of the low-degree extension domain.
    #    trace_domain_bits: The log2 of the trace domain.
    #    fold_arities: A list of the log2 of the folding factors used in the FRI protocol.
    #    num_polys: The degree of the batching plus 1 e.g. for linear batching it is equal to 2.

    m = 3
    return commit_soundness_error_list(field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, m) + 1


def query_soundness_error_list(lde_domain_bits, trace_domain_bits, num_queries, m, quotient_degree=0, grinding_bits=0):
    # Returns the log2 soundness error of the FRI query phase

    # Parameters:
    #    lde_domain_bits: The log2 of the low-degree extension domain.
    #    trace_domain_bits: The log2 of the trace domain.
    #    num_queries: The number of queries during the FRI query phase.
    #    m: The proximity paramater to the Johnson bound.
    #    quotient_degree: The maximal degree of the denominators appearing in the evaluation quotients.
    #    grinding_bits: The number of grinding bits in the proof-of-work.

    if m < 3:
        print("Proximity parameter m cannot be less than 3")
        return
    trace_len = 2**trace_domain_bits
    domain = 2**lde_domain_bits
    rho_plus = (trace_len + quotient_degree)/domain
    rate_bits = -log2(rho_plus)

    return num_queries * (log2(1 + (1/(2*m))) - rate_bits/2) - grinding_bits


def num_samples_list(security_bits, lde_domain_bits, trace_domain_bits, m, quotient_degree=0, grinding_bits=0, max_num_queries=200):
    # Returns the least number of queries needed to reach a certain security number of bits.

    # Parameters:
    #    security_bits: The number of target bits security.
    #    lde_domain_bits: The log2 of the low-degree extension domain.
    #    trace_domain_bits: The log2 of the trace domain.
    #    m: The proximity paramater to the Johnson bound.
    #    quotient_degree: The maximal degree of the denominators appearing in the evaluation quotients.
    #    grinding_bits: The number of grinding bits in the proof-of-work.
    #    max_num_queries: An upper bound on the number of allowed queries.

    if m < 3:
        print("Proximity parameter m cannot be less than 3")
        return
    num_queries = 1
    while query_soundness_error_list(lde_domain_bits, trace_domain_bits, num_queries, m, quotient_degree, grinding_bits) > -security_bits and num_queries < max_num_queries:
        num_queries += 1
    return num_queries


def proximity_parameter(security_bits, field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, m_max=10**7):
    # Returns the largest proximity parameter that is sufficient to reach a certain security number of bits.

    # Parameters:
    #    security_bits: The number of target bits security.
    #    field_bits: The number of bits of the field we are drawing the challenges from.
    #    lde_domain_bits: The log2 of the low-degree extension domain.
    #    trace_domain_bits: The log2 of the trace domain.
    #    fold_arities: A list of the log2 of the folding factors used in the FRI protocol.
    #    num_polys: The degree of the batching plus 1 e.g. for linear batching it is equal to 2.
    #    m_max: An upper bound on the size of the proximity parameter.

    m = 3
    current_security_bits = - commit_soundness_error_list(
        field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, m)

    if current_security_bits < security_bits:
        print("Target security bits is not reachable from the current parameters")
        return -1
    while current_security_bits > security_bits and m < m_max:
        m += 1
        current_security_bits = - commit_soundness_error_list(
            field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, m)
    return m-1



# Helper function for making examples
def example(field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, quotient_degree, target_security):
    print("Field number of bits", field_bits)
    print("LDE domain size 2^", lde_domain_bits)
    print("Trace domain size 2^", trace_domain_bits)
    print("Fold arities ", fold_arities)
    print("Number of polynomials in the batch ", num_polys)
    print("Correction factor of rho+ ", quotient_degree)

    min_error = min_achievable_soundness_error(
        field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys)
    print("Smallest achievable soundness error 2^", min_error)
    if target_security > -min_error:
        m = 3
        print("Target security is unachievable, the maximum achievable is", -min_error)
        num_queries = num_samples_list(-min_error + 1, lde_domain_bits,
                                    trace_domain_bits, m, quotient_degree, grinding_bits=0, max_num_queries=200)
        print("The number of queries required to achieve this with 0-bits of grinding", num_queries)
        num_queries = num_samples_list(-min_error + 1, lde_domain_bits, trace_domain_bits,
                                    m, quotient_degree, grinding_bits=16, max_num_queries=200)
        print("The number of queries required to achieve this with 16-bits of grinding", num_queries)
        commit_error = commit_soundness_error_list(
            field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, m)
        print("Commit phase soundness", -commit_error)
        query_error = query_soundness_error_list(
            lde_domain_bits, trace_domain_bits, num_queries, m, quotient_degree=0, grinding_bits=16)
        print("Query phase soundness", -query_error)
        print("The total soundness of FRI is",int(min(-query_error, -commit_error)) - 1, "bits")
    else:
        m = proximity_parameter(target_security + 1, field_bits, lde_domain_bits,
                                trace_domain_bits, fold_arities, num_polys, m_max=10**7)
        print("Target security is achievable with proximity parameter m", m)

        num_queries = num_samples_list(target_security + 1, lde_domain_bits, trace_domain_bits,
                                    m, quotient_degree, grinding_bits=0, max_num_queries=200)
        print("The number of queries required to achieve this with 0-bits of grinding", num_queries)
        num_queries = num_samples_list(target_security + 1, lde_domain_bits, trace_domain_bits,
                                    m, quotient_degree, grinding_bits=16, max_num_queries=200)
        print("The number of queries required to achieve this with 16-bits of grinding", num_queries)
        commit_error = commit_soundness_error_list(
            field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, m)
        print("Commit phase soundness", -commit_error)
        query_error = query_soundness_error_list(
            lde_domain_bits, trace_domain_bits, num_queries, m, quotient_degree=0, grinding_bits=16)
        print("Query phase soundness", -query_error)
        print("The total soundness of FRI is",int(min(-query_error, -commit_error)) - 1, "bits")


print("==============================================================")
print("==========================Example 1===========================")
print("==============================================================")
target_security = 80
field_bits = 2*64
lde_domain_bits = 15+3
trace_domain_bits = 15
fold_arities = [5, 4, 1]
num_polys = 2
quotient_degree = 0

example(field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, quotient_degree, target_security)


print("==============================================================")
print("==========================Example 2===========================")
print("==============================================================")
print("This is basically Example 1 but with a cubic extension field.")
print("This allows reaching the target security of 80 bits.")
target_security = 80
field_bits = 3*64
lde_domain_bits = 15+3
trace_domain_bits = 15
fold_arities = [5, 4, 1]
num_polys = 2
quotient_degree = 0

example(field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, quotient_degree, target_security)

print("==============================================================")
print("==========================Example 3===========================")
print("==============================================================")
print("This is basically Example 2 but with a higher blowup factor.")
print("This allows reaching the target security of 80 bits but with smaller number of queries.")
target_security = 80
field_bits = 3*64
lde_domain_bits = 20+5
trace_domain_bits = 20
fold_arities = [5, 4, 1]
num_polys = 2
quotient_degree = 0

example(field_bits, lde_domain_bits, trace_domain_bits, fold_arities, num_polys, quotient_degree, target_security)